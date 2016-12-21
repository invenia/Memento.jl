@testset "Handlers" begin
    FMT_STR = "[{level}]:{name} - {msg}"

    LEVELS = Dict(
        :debug => 10,
        :info => 20,
        :warn => 30,
        :error => 40,
        :fubar => 50
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
                    :info,
                    LEVELS,
                    default_record
                )

                @test logger.name == "DefaultHandler.sample_io"
                @test logger.level == :info

                info("Starting IOBuffer tests")
                msg = "It works!"
                Lumberjack.info(logger, msg)
                @test takebuf_string(io) == "[info]:$(logger.name) - $msg\n"

                Lumberjack.debug(logger, "This shouldn't get logged")
                @test takebuf_string(io) == ""

                msg = "Something went very wrong"
                log(logger, :fubar, msg)
                @test takebuf_string(io) == "[fubar]:$(logger.name) - $msg\n"
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
                :info,
                LEVELS,
                default_record
            )

            @test logger.name == "DefaultHandler.sample_file"
            @test logger.level == :info

            Lumberjack.info(logger, "It works!")
            Lumberjack.debug(logger, "This shouldn't get logged")

            log(logger, :fubar, "Something went very wrong")

            @test success(`rm $filename`)
        end

        @testset "IO Construction" begin
            io = IOBuffer()
            try
                handler1 = DefaultHandler(io)

                @test handler1.fmt.fmt_str == Lumberjack.DEFAULT_FMT_STRING
                @test takebuf_string(handler1.io) == ""
                @test !(handler1.opts[:is_colorized])

                handler2 = DefaultHandler(
                    io,
                    DefaultFormatter(FMT_STR),
                    Dict{Symbol, Any}(:is_colorized => true)
                )

                @test handler2.fmt.fmt_str == FMT_STR
                @test handler2.opts[:is_colorized]
                @test haskey(handler2.opts, :colors)
                @test haskey(handler2.opts[:colors], :debug)
                @test handler2.opts[:colors][:debug] == :cyan
            finally
                close(io)
            end
        end

        @testset "Filename Construction" begin
            filename = tempname()
            info("Path to log file: $filename")
            handler1 = DefaultHandler(filename)

            @test handler1.fmt.fmt_str == Lumberjack.DEFAULT_FMT_STRING
            @test !(handler1.opts[:is_colorized])

            handler2 = DefaultHandler(
                filename,
                DefaultFormatter(FMT_STR),
                Dict{Symbol, Any}(:is_colorized => true)
            )

            @test handler2.fmt.fmt_str == FMT_STR
            @test handler2.opts[:is_colorized]
            @test haskey(handler2.opts, :colors)
            @test haskey(handler2.opts[:colors], :debug)
            @test handler2.opts[:colors][:debug] == :cyan
        end
    end
end
