@testset "Loggers" begin
    FMT_STR = "[{level}]:{name} - {msg}"

    LEVELS = Dict(
        "debug" => 10,
        "info" => 20,
        "warn" => 30,
        "error" => 40,
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
                "error",
                LEVELS,
                default_record
            )

            @test logger.name == "Logger.example"
            @test logger.level == "error"
            @test length(get_handlers(logger)) == 1

            add_handler(logger, DefaultHandler(tempname()), "filehandler")
            @test length(get_handlers(logger)) == 2

            remove_handler(logger, "filehandler")
            @test length(get_handlers(logger)) == 1

            set_level(logger, "info")
            @test logger.level == "info"

            add_level(logger, "fubar", 50)

            info("Starting IOBuffer tests")
            msg = "It works!"
            Lumberjack.info(logger, msg)
            @test takebuf_string(io) == "[info]:Logger.example - $msg\n"

            Lumberjack.debug(logger, "This shouldn't get logged")
            @test takebuf_string(io) == ""

            msg = "Something went very wrong"
            log(logger, "fubar", msg)
            @test takebuf_string(io) == "[fubar]:Logger.example - $msg\n"

            new_logger = Logger("new_logger")
        finally
            close(io)
        end
    end
end
