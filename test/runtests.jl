using Compat
using Compat.Test

import Compat: Dates
import Compat:Sys

files = [
    "records.jl",
    "formatters.jl",
    "handlers.jl",
    "loggers.jl",
    "io.jl",
    "concurrency.jl",
    "ext/json.jl",
]

Sys.isunix() ? push!(files, "ext/syslogs.jl") : nothing
haskey(ENV, "MEMENTO_BENCHMARK") ? files = ["benchmarks.jl"] : nothing

using Memento

cd(dirname(@__FILE__))

@testset "Logging" begin
    @testset "Sample Usage" begin
        Memento.config("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
        logger1 = get_logger(@__MODULE__)
        debug(logger1, "Something that won't get logged.")
        info(logger1, "Something you might want to know.")
        warn(logger1, "This might cause an error.")
        warn(logger1, ErrorException("A caught exception that we want to log as a warning."))
        @test_throws ErrorException error(logger1, "Something that should throw an error.")
        @test_throws ErrorException error(logger1, ErrorException("A caught exception that we should log and rethrow"))
        logger2 = get_logger("Pkg.Foo.Bar")
    end

    @testset "Logger Hierarchy" begin
        Memento.reset!()
        foo = get_logger("Foo")
        bar = get_logger("Foo.Bar")
        baz = get_logger("Foo.Bar.Baz")
        car = get_logger("Foo.Car")

        for l in (foo, bar, baz, car)
            @test is_set(l)
            @test get_level(l) == "warn"
            @test length(get_handlers(l)) == 0
        end

        io = IOBuffer()

        try
            set_level(get_logger(), "info")
            add_handler(
                get_logger(),
                DefaultHandler(io, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            msg = "This should propagate to the root logger."
            warn(baz, msg)
            result = String(take!(io))
            expected = "Foo.Bar.Baz - warn: $msg"
            @test contains(result, expected)

            set_level(baz, "debug")
            add_handler(
                baz,
                DefaultHandler(io, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            msg = "Message"
            warn(baz, msg)
            str = String(take!(io))

            # The message should be written twice for "root" and "Foo.Bar.Baz"
            @test length(str) > length("Foo.Bar.Baz - warn: $msg") * 2

            debug(baz, msg)
            # Test that the "root" logger won't print anything bug the baz logger will
            # because of their respective logging levels
            @test contains(String(take!(io)), "Foo.Bar.Baz - debug: $msg")

            info(car, msg)
            # the Foo.Car logger should still be unaffected.
            @test contains(String(take!(io)), "Foo.Car - info: $msg")
        finally
            close(io)
        end
    end

    @testset "Default Levels" begin
        @test allunique(values(Memento._log_levels))
    end
end


# Test files should assume the global _loggers has been reset
for file in files
    Memento.reset!()
    include(abspath(file))
end
