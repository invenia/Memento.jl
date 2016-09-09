import Base.println, Base.flush

# Define valid syslog levels and common aliases.
SYSLOG_LEVELS = [:emerg, :alert, :crit, :err, :warning, :notice, :info, :debug]
ALIAS_LEVELS = Dict(:warn=>:warning, :error=>:err, :emergency=>:emerg, :critical=>:crit)

# Define valid syslog facilities (even kern, which isn't accessible from userspace).
FACILITIES = [
    :auth, :authpriv, :cron, :daemon, :ftp, :kern, :lpr, :mail, :news, :syslog, :user,
    :uucp, :local0, :local1, :local2, :local3, :local4, :local5, :local6, :local7, :security
]

type Syslog <: IO
    facility::Symbol
    tag::AbstractString
    pid::Integer

    function Syslog(facility=:local0, tag="julia", tag_pid::Bool=false)
        # Verify that logger is installed.
        if !success(`which logger`)
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

function println(log::Syslog, level::Symbol, msg::AbstractString)
    level = get(ALIAS_LEVELS, level, level)
    if !(level in SYSLOG_LEVELS)
        throw(ErrorException("invalid level: $level"))
    end

    tag = log.tag * (log.pid > -1 ? "[$(log.pid)]" : "")

    # @mendable is required to allow the test cases to modify the run command for testing.
    # TODO: figure out how Mocking works with 0.5
    #@mendable run(`logger -t $(tag) -p $(log.facility).$level $msg`)
    run(`logger -t $(tag) -p $(log.facility).$level $msg`)
end

function println(log::Syslog, level::AbstractString, msg::AbstractString)
    println(log, @compat(Symbol)(lowercase(level)), msg)
end

# Defined just in case somebody decides to call flush, which is totally unnecessary.
flush(log::Syslog) = log
