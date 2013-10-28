
module Lumberjack

import Base.show

using Datetime

# -------

abstract LogFormat

# -------

type CommonLog <: LogFormat
    remotehost
    rfc931
    authuser
    #date
    request
    status
    bytes

    CommonLog() = new()
    CommonLog(remotehost, rfc931, authuser, request, status, bytes) = new(remotehost, rfc931, authuser, request, status, bytes)
end

function show(io::IO, l::CommonLog)
    date = now()
    print(io, "$(l.remotehost) $(l.rfc931) $(l.authuser) [$date] \"$(l.request)\" $(l.status) $(l.bytes)")
end

# -------

type ExtendedLog <: LogFormat
end

# -------

type LumberMill
    mode    # debug, release
    io::IO
    fmt::LogFmt

    LumberMill() = new("debug", Base.STDOUT, CommonLog())
    LumberMill(mode::String, io::IO) = new(mode, io)
end

global lumber_mill = LumberMill()

# -------

function output_to(io::IO)
    lumber_mill.io = io
end

end
