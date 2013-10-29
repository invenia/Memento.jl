
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
    CommonLog(lvl, msg, meta) = CommonLog(get(meta, "remotehost", ""), get(meta, "rfc931", ""), get(meta, "authuser", ""), get(meta, "request", ""), get(meta, "status", ""), get(meta, "bytes", ""))
    CommonLog(remotehost, rfc931, authuser, request, status, bytes) = new(remotehost, rfc931, authuser, request, status, bytes)
end

function show(io::IO, l::CommonLog)
    date = now()
    print(io, "$(l.remotehost) $(l.rfc931) $(l.authuser) [$date] \"$(l.request)\" $(l.status) $(l.bytes)")
end

# -------

type LumberjackLog <: LogFormat
    args::Dict
end

function show(io::IO, l::LumberjackLog)

end

# -------