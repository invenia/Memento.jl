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

    @testset "DefaultHandler" begin
        @testset "Sample Usage w/ IO" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(
                    io, DefaultFormatter(FMT_STR)
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
                @test contains(takebuf_string(io), "[info]:$(logger.name) - $msg")

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(takebuf_string(io))

                msg = "Something went very wrong"
                log(logger, "fubar", msg)
                @test contains(takebuf_string(io), "[fubar]:$(logger.name) - $msg")
            finally
                close(io)
            end
        end

        @testset "Sample Usage w/ File" begin
            filename = tempname()
            info("Path to log file: $filename")

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
            @test is_windows() ? true : success(`rm $filename`)
        end

        @testset "IO Construction" begin
            io = IOBuffer()
            try
                handler1 = DefaultHandler(io)

                @test handler1.fmt.fmt_str == Memento.DEFAULT_FMT_STRING
                @test isempty(takebuf_string(handler1.io))
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
            info("Path to log file: $filename")
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
                @test contains(takebuf_string(io), "[info]:$(logger.name) - $msg")

                Memento.debug(logger, "This shouldn't get logged")
                @test isempty(takebuf_string(io))

                msg = "Something went very wrong"
                log(logger, "fubar", msg)
                @test contains(takebuf_string(io), "[fubar]:$(logger.name) - $msg")
            finally
                close(io)
            end
        end

        @testset "Level Filter" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(
                    io, DefaultFormatter(FMT_STR)
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
                @test contains(takebuf_string(io), "[info]:$(logger.name) - $msg")

                # Filter out log messages < LEVELS["warn"]
                set_level(handler, "warn")
                # add_filter(
                #     handler,
                #     Filter((rec) -> rec[:levelnum] >= LEVELS["warn"])
                # )

                Memento.info(logger, "This shouldn't get logged")
                @test isempty(takebuf_string(io))
            finally
                close(io)
            end
        end
    end
end
