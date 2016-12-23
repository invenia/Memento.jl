
using Base.Test
using Mocking
Mocking.enable()

using Memento
using JSON

cd(dirname(@__FILE__))
files = [
    "io.jl",
    "records.jl",
    "formatters.jl",
    "handlers.jl",
    "loggers.jl",
]

@testset "Logging" begin
    @testset "Sample Usage" begin
        basic_config("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
        logger1 = get_logger(current_module())
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
            @test !is_set(l)
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
            @test takebuf_string(io) == "Foo.Bar.Baz - warn: $msg\n"

            set_level(baz, "debug")
            add_handler(
                baz,
                DefaultHandler(io, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            msg = "Message"
            warn(baz, msg)
            str = takebuf_string(io)

            # The message should be written twice for "root" and "Foo.Bar.Baz"
            @test length(str) == length("Foo.Bar.Baz - warn: $msg\n") * 2

            debug(baz, msg)
            # Test that the "root" logger won't print anything bug the baz logger will
            # because of their respective logging levels
            @test takebuf_string(io) == "Foo.Bar.Baz - debug: $msg\n"

            info(car, msg)
            # the Foo.Car logger should still be unaffected.
            @test takebuf_string(io) == "Foo.Car - info: $msg\n"
        finally
            close(io)
        end
    end

    @testset "Async Logging" begin
        Memento.reset!()
        io = IOBuffer()

        try
            set_level(get_logger(), "info")
            add_handler(
                get_logger(),
                DefaultHandler(io, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            asyncmap(x -> warn(get_logger(), "message"), 1:10)
            all_msgs = split(takebuf_string(io), "\n")

            @test !isempty(all_msgs)
            @test all(m -> m == all_msgs[1], all_msgs[2:end-1])
        finally
            close(io)
        end
    end

    # TODO: Look into getting Parallel logging test working.
    # Currently, multiprocessing doesn't work with --compilecache=no
    # needed for the mocking tests to working.

    # @testset "Parallel Logging" begin
    #     Memento.reset!()
    #     numprocs = addprocs(2)
    #
    #     try
    #         # broadcast a filename to write to.
    #         @eval @everywhere parallel_test_filename = $(tempname())
    #
    #         @everywhere using Memento
    #         @everywhere set_level(get_logger(), "info")
    #         @everywhere add_handler(
    #             get_logger(),
    #             DefaultHandler(parallel_test_filename, DefaultFormatter("{name} - {level}: {msg}")),
    #             "io"
    #         )
    #
    #         pmap(x -> warn(get_logger(), "message"), 1:10)
    #
    #         open(parallel_test_filename) do f
    #             all_msgs = readlines(f)
    #             # @test !isempty(all_msgs)
    #             @test all(m -> m == all_msgs[1], all_msgs[2:end])
    #         end
    #
    #         @test success(`rm $parallel_test_filename`)
    #     finally
    #         rmprocs(numprocs)
    #     end
    # end
end


# Test files should assume the global _loggers has been reset
for file in files
    Memento.reset!()
    include(abspath(file))
end
