@testset "Handlers" begin
    FMT_STR = "[{level}]:{name} - {msg}"

    LEVELS = Dict(
        "not_set" => 0,
        "debug" => 10,
        "info" => 20,
        "warn" => 30,
        "error" => 40,
        "fubar" => 50
    )

    @testset "Custom Handlers" begin
        @testset "SimplestHandler" begin
            io = IOBuffer()

            try
                handler = SimplestHandler(io)
                logger = Logger(
                    "SimplestHandler",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test getlevel(handler) == "not_set"
                @test isempty(getfilters(handler))

                msg = "It works!"
                Memento.info(logger, msg)
                @test occursin(msg, String(take!(io)))

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(String(take!(io)))
            finally
                close(io)
            end
        end

        @testset "FilterHandler" begin
            io = IOBuffer()

            try
                handler = FilterHandler(io)
                handler_filter = Memento.Filter(handler)
                push!(handler, handler_filter)
                logger = Logger(
                    "FilterHandler",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test getlevel(handler) == "not_set"
                @test getfilters(handler) == [handler_filter]

                msg = "It works!"
                Memento.info(logger, msg)
                @test occursin(msg, String(take!(io)))

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(String(take!(io)))
            finally
                close(io)
            end
        end

        @testset "AsyncHandler" begin
            io = IOBuffer()

            function wait_for_empty(c::Channel)
                while isready(c)
                    sleep(1)
                end
            end

            try
                handler = AsyncHandler(io)
                logger = Logger(
                    "AsyncHandler",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test getlevel(handler) == "not_set"
                @test isempty(getfilters(handler))

                msg = "It works!"
                Memento.info(logger, msg)
                wait_for_empty(handler.channel)
                @test occursin(msg, String(take!(io)))

                Memento.debug(logger, "This shouldn't get logged")
                wait_for_empty(handler.channel)
                @test isempty(String(take!(io)))

                # Asynchronous handlers can cause issues when loggers are used across
                # multiple processes. We'll emulate the following issue:
                #=
                using Distributed, Memento
                const LOGGER = getlogger()
                addprocs(1)
                @everywhere using Memento
                # Note: Define AsyncHandler on all processes
                @everywhere push!(getlogger(), AsyncHandler(IOBuffer()))
                pmap(1:3) do i
                    Memento.info(LOGGER, i)  # ERROR: cannot serialize a running Task
                end
                =#
                if VERSION < v"1.8.0-beta1"
                    try
                        serialize(io, handler)
                        @test false
                    catch e
                        @test e isa ErrorException
                        @test e.msg == "cannot serialize a running Task"
                    end

                    @test_throws LoggerSerializationError serialize(io, logger)
                end
            finally
                close(io)
            end
        end
    end

    @testset "DefaultHandler" begin
        @testset "Sample Usage w/ IO" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

                logger = Logger(
                    "DefaultHandler.sample_io",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test logger.name == "DefaultHandler.sample_io"
                @test logger.level == "info"

                msg = "It works!"
                Memento.info(logger, msg)
                @test occursin("[info]:$(logger.name) - $msg", String(take!(io)))

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(String(take!(io)))

                msg = "Something went very wrong"
                log(logger, "fubar", msg)
                @test occursin("[fubar]:$(logger.name) - $msg", String(take!(io)))
            finally
                close(io)
            end
        end

        @testset "Sample Usage w/ File" begin
            filename = tempname()
            @info("Path to log file: $filename")

            handler = DefaultHandler(filename)

            logger = Logger(
                "DefaultHandler.sample_file",
                Dict("File" => handler),
                "info",
                LEVELS,
                DefaultRecord,
                true
            )

            @test logger.name == "DefaultHandler.sample_file"
            @test logger.level == "info"

            Memento.info(logger, "It works!")
            Memento.debug(logger, "This shouldn't get logged")

            log(logger, "fubar", "Something went very wrong")

            @test isfile(filename)
            @test Sys.iswindows() ? true : success(`rm $filename`)
        end

        @testset "IO Construction" begin
            io = IOBuffer()
            try
                handler1 = DefaultHandler(io)

                @test handler1.fmt.fmt_str == Memento.DEFAULT_FMT_STRING
                @test isempty(String(take!(handler1.io)))
                @test !(handler1.opts[:is_colorized])

                handler2 = DefaultHandler(
                    io,
                    DefaultFormatter(FMT_STR),
                    Dict{Symbol, Any}(:is_colorized => true)
                )

                @test handler2.fmt.fmt_str == FMT_STR
                @test handler2.opts[:is_colorized]
                @test haskey(handler2.opts, :colors)
                @test haskey(handler2.opts[:colors], "debug")
                @test handler2.opts[:colors]["debug"] == :blue
            finally
                close(io)
            end
        end

        @testset "Filename Construction" begin
            filename = tempname()
            @info("Path to log file: $filename")
            handler1 = DefaultHandler(filename)

            @test handler1.fmt.fmt_str == Memento.DEFAULT_FMT_STRING
            @test !(handler1.opts[:is_colorized])

            handler2 = DefaultHandler(
                filename,
                DefaultFormatter(FMT_STR),
                Dict{Symbol, Any}(:is_colorized => true)
            )

            @test handler2.fmt.fmt_str == FMT_STR
            @test handler2.opts[:is_colorized]
            @test haskey(handler2.opts, :colors)
            @test haskey(handler2.opts[:colors], "debug")
            @test handler2.opts[:colors]["debug"] == :blue
        end

        @testset "Colors" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(
                    io, DefaultFormatter(FMT_STR),
                    Dict{Symbol, Any}(
                        :is_colorized => true,
                        :colors => Dict{AbstractString, Symbol}(
                            "debug" => :black,
                            "info" => :blue,
                            "notice" => :green,
                            "warn" => :cyan,
                            "error" => :magenta,
                            "critical" => :red,
                            "alert" => :yellow,
                            "emergency" => :white,
                        )
                    )
                )

                logger = Logger(
                    "DefaultHandler.sample_io",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test logger.name == "DefaultHandler.sample_io"
                @test logger.level == "info"

                msg = "It works!"
                Memento.info(logger, msg)
                @test occursin("[info]:$(logger.name) - $msg", String(take!(io)))

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(String(take!(io)))

                msg = "Something went very wrong"
                log(logger, "fubar", msg)
                @test occursin("[fubar]:$(logger.name) - $msg", String(take!(io)))
            finally
                close(io)
            end
        end

        @testset "Level Filter" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

                logger = Logger(
                    "DefaultHandler.sample_io",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                @test logger.name == "DefaultHandler.sample_io"
                @test logger.level == "info"

                msg = "It works!"
                Memento.info(logger, msg)
                @test occursin("[info]:$(logger.name) - $msg", String(take!(io)))

                # Filter out log messages < LEVELS["warn"]
                setlevel!(handler, "warn")
                # add_filter(
                #     handler,
                #     Filter((rec) -> rec.levelnum >= LEVELS["warn"])
                # )

                Memento.info(logger, "This shouldn't get logged")
                @test isempty(String(take!(io)))
            finally
                close(io)
            end
        end
    end

    @testset "Escalator" begin
        @testset "Basic" begin
            # Using default behaviour to convert warnings to errors
            handler = Escalator()
            logger = Logger(
                "Escalator.basic",
                Dict("Escalator" => handler),
                "info",
                LEVELS,
                DefaultRecord,
                true,
            )

            # Info messages should work fine as no-ops
            info(logger, "Hello World!")

            # Test that we throw an escalation error for warnings
            @test_throws Memento.EscalationError warn(logger, "Goodbye World!")
        end

        @testset "info" begin
            # Using default behaviour to convert notice and warnings to errors
            handler = Escalator()
            setlevel!(handler, "info")
            logger = Logger(
                "Escalator.basic",
                Dict("Escalator" => handler),
                "info",
                LEVELS,
                DefaultRecord,
                true,
            )

            # Test that we throw an escalation error for info messages
            @test_throws Memento.EscalationError info(logger, "Goodbye World!")

            # Test that we throw an escalation error for warnings
            @test_throws Memento.EscalationError warn(logger, "Goodbye World!")
        end

        @testset "stdlib" begin
            # Test escalating base logging records
            orig_logger = Base.CoreLogging.global_logger()
            base_logger = Memento.BaseLogger(min_enabled_level(global_logger()))
            logger = getlogger(string(@__MODULE__))

            try
                global_logger(base_logger)
                push!(logger, Escalator())
                @test_throws Memento.EscalationError @warn("Goodbye World!")
            finally
                # Remove the logger and replace the core logging
                delete!(Memento._loggers, string(@__MODULE__))
                global_logger(orig_logger)
            end
        end
    end
end
