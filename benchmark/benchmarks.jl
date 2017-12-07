using PkgBenchmark
using Memento

const FMT_STR = "[{level}|{name}] - {msg}"

"""
Sets up our memento logger with a given formatter.
"""
function memento_setup(fmt=DefaultFormatter(FMT_STR))
    return Logger(
        "Benchmarks",
        Dict("Buffer" => DefaultHandler(IOBuffer(),fmt)),
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

"""
Builds up a log message comparable to the default log messages
produced in Memento w/ the option to sleep to mimic expensive message
generations.
"""
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

"""
Mocks passing the memento message as a funtion w/
the option to sleep to mimic expensive message generation functions.
"""
function memento_msg(msg; sleep_time=0.0)
    function inner_func()
        sleep(sleep_time)
        return msg
    end
end

# Some basic benchmarks of logging in base julia as a point of reference.
@benchgroup "Base" begin
    @bench(
        "Logging raw string",
        info(io, "[info|Base] - Msg"),
        setup=(io = IOBuffer()),
    )
    @bench(
        "Loggin with interpolation (delay 0.0)",
        info(io, base_msg("info", "Base", "Msg")()),
        setup=(io = IOBuffer()),
    )
    @bench(
        "Logging with interpolation (delay 0.1)",
        info(io, base_msg("info", "Base", "Msg"; sleep_time=0.1)()),
        setup=(io = IOBuffer()),
    )
end

# All our Memento.jl benchmarks.
# NOTE: we're trying to mostly benchmark the general API rather than
# individual components as the implementation may change significantly between
# iterations.
@benchgroup "Memento" begin
    @bench(
        "Unfiltered log (delay 0.0)",
        info(memento_msg("Msg"), logger),
        setup=(logger = memento_setup()),
    )
    @bench(
        "Filtered log (delay 0.0)",
        debug(memento_msg("Msg"), logger),
        setup=(logger = memento_setup()),
    )
    @bench(
        "Unfiltered log (delay 0.1)",
        info(memento_msg("Msg"; sleep_time=0.1), logger),
        setup=(logger = memento_setup()),
    )
    @bench(
        "Filtered log (delay 0.1)",
        debug(memento_msg("Msg"; sleep_time=0.1), logger),
        setup=(logger = memento_setup()),
    )
    @bench(
        "Unfiltered log with StackTrace",
        info(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DefaultFormatter("[{level}] - {msg} -> {stacktrace}"))),
    )
    @bench(
        "Filtered log with StackTrace",
        debug(memento_msg("Msg"; sleep_time=0.1), logger),
        setup=(logger = memento_setup(DefaultFormatter("[{level}] - {msg} -> {stacktrace}"))),
    )
    @bench(
        "Unfiltered log as JSON (no aliases)",
        info(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter())),
    )
    @bench(
        "Filtered log as JSON (no aliases)",
        debug(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter())),
    )
    no_trace_aliases = Dict(
        :message => :msg,
        :level => :level,
        :logger => :name,
    )
    @bench(
        "Unfiltered log as JSON (aliases w/o trace)",
        info(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter($no_trace_aliases))),
    )
    @bench(
        "Filtered log as JSON (aliases w/o trace)",
        debug(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter($no_trace_aliases))),
    )
    trace_aliases = Dict(
        :backtrace => :stacktrace,
        :message => :msg,
        :level => :level,
        :logger => :name,
    )
    @bench(
        "Unfiltered log as JSON (aliases w/ trace)",
        info(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter($trace_aliases))),
    )
    @bench(
        "Filtered log as JSON (aliases w/ trace)",
        debug(memento_msg("Msg"), logger),
        setup=(logger = memento_setup(DictFormatter($trace_aliases))),
    )
end
