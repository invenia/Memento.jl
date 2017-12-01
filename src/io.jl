import Base.println, Base.flush

const DEFAULT_MAX_FILE_SIZE = 5000 * 1028

"""
    FileRoller <: IO

Is responsible for managing a rolling
log file.

# Fields
* `prefix::AbstractString`: filename prefix for the log.
* `folder::AbstractString`: directory where the log should be written.
* `file::AbstractString`: the current file IO handle
* `byteswritten::Int64`: keeps track of how many bytes have been written to the current file.
* `max_sz::Int`: the maximum number of bytes written to a file before rolling over to another.
"""
mutable struct FileRoller <: IO
    prefix::AbstractString
    folder::AbstractString
    filepath::AbstractString
    file::IO
    byteswritten::Int64
    max_sz::Int
end

"""
    getsuffix(::Integer) -> String

Formats the nth file suffix.
"""
function getsuffix(n::Integer)
    str = string(n)
    for i = 1:(4 - length(str))
        str = "0"*str
    end
    str
end

"""
    getfile(folder::AbstractString, prefix::AbstractString) -> String, IO

Grabs the next log file.
"""
function getfile(folder::AbstractString, prefix::AbstractString)
    i = 1
    getpath(i) = joinpath(folder, "$(prefix).$(getsuffix(i))")
    p = getpath(i)
    while isfile(p)
        p = getpath(i)
        i += 1
    end
    p, open(p, "a")
end

"""
    FileRoller(prefix; max_size=DEFAULT_MAX_FILE_SIZE)

Creates a rolling log file in the current working directory
with the specified prefix.
"""
FileRoller(prefix; max_sz=DEFAULT_MAX_FILE_SIZE) = FileRoller(prefix, pwd(); max_sz=max_sz)

"""
    FileRoller(prefix, dir; max_size=DEFAULT_MAX_FILE_SIZE)

Creates a rolling log file in the specified directory with the given prefix.
"""
function FileRoller(prefix, dir; max_sz=DEFAULT_MAX_FILE_SIZE)
    FileRoller(prefix, dir, (getfile(dir, prefix))..., 0, max_sz)
end

"""
    println(::FileRoller, ::AbstractString)

Writes the string to a file and creates a new file if
we've reached the max file size.
"""
function println(f::FileRoller, s::AbstractString)
    if f.byteswritten > f.max_sz
        gf = getfile(f.folder, f.prefix)
        f.filepath = gf[1]
        f.file = gf[2]
        f.byteswritten = 0
    end
    f.byteswritten += write(f.file, "$s\n")
end

"""
    flush(::FileRoller)

Flushes the current open file.
"""
flush(f::FileRoller) = flush(f.file)

# Define valid syslog levels and common aliases.
SYSLOG_LEVELS = [:emerg, :alert, :crit, :err, :warning, :notice, :info, :debug]
ALIAS_LEVELS = Dict(:warn=>:warning, :error=>:err, :emergency=>:emerg, :critical=>:crit)

# Define valid syslog facilities (even kern, which isn't accessible from userspace).
FACILITIES = [
    :auth, :authpriv, :cron, :daemon, :ftp, :kern, :lpr, :mail, :news, :syslog, :user,
    :uucp, :local0, :local1, :local2, :local3, :local4, :local5, :local6, :local7, :security
]

"""
    Syslog <: IO

`Syslog` handle writing message to `syslog` by shelling out to the
`logger` command.

# Fields
* `facility::Symbol`: The syslog facility to write to (e.g., :local0, :ft, :daemon, etc) (defaults to :local0)
* `tag::AbstractString`: a tag to use for all message (defaults to "julia")
* `pid::Integer`: tags julia's pid to messages (defaults to -1 which doesn't include the pid)
"""
mutable struct Syslog <: IO
    facility::Symbol
    tag::AbstractString
    pid::Integer

    function Syslog(facility=:local0, tag="julia", tag_pid::Bool=false)
        # Verify that logger is installed.
        has_logger = try @mock success(`which logger`) end
        if has_logger == nothing || !has_logger
            error("syslog output only available on systems with logger installed")
        end

        if !(facility in FACILITIES)
            error("invalid logging facility: $(facility)")
        end

        # Appends Julia's process ID to the log tag if show_pid is specified.
        pid = tag_pid ? getpid() : -1

        new(facility, tag, pid)
    end
end

"""
    println(::Syslog, ::Symbol, ::AbstractString)

Writes the AbstractString to `logger` with the Symbol
representing the syslog level.
"""
function println(log::Syslog, level::Symbol, msg::AbstractString)
    level = get(ALIAS_LEVELS, level, level)
    if !(level in SYSLOG_LEVELS)
        throw(ErrorException("invalid level: $level"))
    end

    tag = log.tag * (log.pid > -1 ? "[$(log.pid)]" : "")

    # @mock is required to allow the test cases to modify the run command for testing.
    @mock run(`logger -t $(tag) -p $(log.facility).$level $msg`)
end

"""
    println(::Syslog, ::AbstractString, ::AbstractString)

Converts the first AbstractString to a Symbol and call
`println(::Syslog, ::Symbol, ::AbstractString)`
"""
function println(log::Syslog, level::AbstractString, msg::AbstractString)
    println(log, Symbol(lowercase(level)), msg)
end

"""
    flush(::Syslog)

Is defined just in case somebody decides to call flush, which is unnecessary.
"""
flush(log::Syslog) = log
