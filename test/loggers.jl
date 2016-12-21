@testset "Loggers" begin
    FMT_STR = "[{level}]:{name} - {msg}"

    LEVELS = Dict(
        :debug => 10,
        :info => 20,
        :warn => 30,
        :error => 40,
        :fubar => 50
    )

    @testset "Example" begin
        io = IOBuffer()

        try
            handler = DefaultHandler(
                io, DefaultFormatter(FMT_STR)
            )

            logger = Logger(
                "Logger.example",
                Dict("Buffer" => handler),
                :info,
                LEVELS,
                default_record
            )

            @test logger.name == "Logger.example"
            @test logger.level == :info

            info("Starting IOBuffer tests")
            msg = "It works!"
            Lumberjack.info(logger, msg)
            @test takebuf_string(io) == "[info]:Logger.example - $msg\n"

            Lumberjack.debug(logger, "This shouldn't get logged")
            @test takebuf_string(io) == ""

            msg = "Something went very wrong"
            log(logger, :fubar, msg)
            @test takebuf_string(io) == "[fubar]:Logger.example - $msg\n"
        finally
            close(io)
        end
    end
end
