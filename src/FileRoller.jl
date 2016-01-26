import Base.println, Base.flush

FILE_SIZE = 5000 * 1028

type FileRoller <: IO
    prefix::AbstractString
    folder::AbstractString
    filepath::AbstractString
    file::IO
    byteswritten::Int64
end

function getsuffix(n::Integer)
    str = string(n)
    for i = 1:(4 - length(str))
        str = "0"*str
    end
    str
end

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

FileRoller(prefix) = FileRoller(prefix, pwd())

FileRoller(prefix, dir) = FileRoller(prefix, dir, (getfile(dir, prefix))..., 0)

function println(f::FileRoller, s::AbstractString)
    if f.byteswritten > FILE_SIZE
        gf = getfile(f.folder, f.prefix)
        f.filepath = gf[1]
        f.file = gf[2]
        f.byteswritten = 0
    end
    f.byteswritten += write(f.file, "$s\n")
end

flush(f::FileRoller) = flush(f.file)
