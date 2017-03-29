using PkgBenchmark
using Memento

const FMT_STR = "[{level}|{name}] - {msg}"

function memento_setup()
    return Logger(
        "Benchmarks",
        Dict(
            "Buffer" => DefaultHandler(
                IOBuffer(),
                DefaultFormatter(FMT_STR)
            ),
        ),
        "info",
        Dict(
           "not_set" => 0,
           "debug" => 10,
           "info" => 20,
           "warn" => 30,
           "error" => 40,
       ),
       DefaultRecord,
       true
    )
end

function base_msg(level, name, msg; sleep_time=0.0)
    d = Dict("level" => level, "name" => name, "msg" => msg)

    function inner_func()
        sleep(sleep_time)

        result = FMT_STR
        for key in ("level", "name", "msg")
            result = replace(result, "{$key}", d[key])
        end

        return result
    end
end

function memento_msg(msg; sleep_time=0.0)
    function inner_func()
        sleep(sleep_time)
        return msg
    end
end

@benchgroup "Common Logging" begin
    @bench "Base.info" info(io, base_msg("info", "Base", "Msg")()) setup=(io = IOBuffer())
    @bench "Memento.info" info(memento_msg("Msg"), logger) setup=(logger = memento_setup())
    @bench "Memento.debug" debug(memento_msg("Msg"), logger) setup=(logger = memento_setup())
end

@benchgroup "Expensive Logging" begin
    @bench(
        "Basic.info",
        info(io, base_msg("info", "Base", "Msg"; sleep_time=0.1)()),
        setup=(io = IOBuffer())
    )
    @bench(
        "Memento.info",
        info(memento_msg("Msg"; sleep_time=0.1), logger),
        setup=(logger = memento_setup())
    )
    @bench(
        "Memento.debug",
        debug(memento_msg("Msg"; sleep_time=0.1), logger),
        setup=(logger = memento_setup())
    )
end
