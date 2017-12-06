using Syslogs

"""
    emit{F, O}(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}

Handles printing any records with any `Formatter` and a `Syslog` `IO` type.
"""
function Memento.emit(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}
    println(handler.io, rec[:level], format(handler.fmt, rec))
    flush(handler.io)
end

# Simple test UDP server
function udp_srv(port::Int)
    r = Future()

    sock = UDPSocket()
    bind(sock, ip"127.0.0.1", port)

    @async begin
        put!(r, String(recv(sock)))
        close(sock)
    end

    return r
end

@testset "Syslogs" begin
    levels = copy(Memento._log_levels)
    levels["invalid"] = 100

    # Run a local UDP server for testing
    r = udp_srv(8080)

    # Create our DefaultHandler w/ the Syslog IO type
    handler = DefaultHandler(
        Syslog(ip"127.0.0.1", 8080; tcp=false),
        DefaultFormatter("{level}: {msg}")
    )

    logger = Logger(
        "Syslogs",
        Dict("Syslog" => handler),
        "debug",
        levels,
        DefaultRecord,
        true
    )

    # We just want to test that our glue code works with Syslogs.jl
    info(logger, "Hello World!")
    s = fetch(r)
    @test contains(s, "Hello World!")
end