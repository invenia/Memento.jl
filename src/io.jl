import Base.println, Base.flush

const DEFAULT_MAX_FILE_SIZE = 5000 * 1028

"""
    FileRoller <: IO

Is responsible for managing a rolling log file.

# Fields
* `prefix::AbstractString`: filename prefix for the log.
* `folder::AbstractString`: directory where the log should be written.
* `filepath::AbstractString`: the full filepath for the log
* `file::IO`: the current file IO handle
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
