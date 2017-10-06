immutable TestError <: Exception
    msg
end

@testset "Loggers" begin
    FMT_STR = "[{level}]:{name} - {msg}"

    LEVELS = Dict(
        "not_set" => 0,
        "debug" => 10,
        "info" => 20,
        "warn" => 30,
        "error" => 40,
    )

    @testset "Simple" begin
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
                DefaultRecord,
                true
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

            set_record(logger, DefaultRecord)

            add_level(logger, "fubar", 50)

            show(io, logger)
            @test contains(String(take!(io)), "Logger(Logger.example)")

            msg = "It works!"
            Memento.info(logger, msg)
            @test contains(String(take!(io)), "[info]:Logger.example - $msg")

            Memento.debug(logger, "This shouldn't get logged")
            @test isempty(String(take!(io)))

            @test_throws TestError Memento.error(logger, TestError("I failed."))
            @test contains(String(take!(io)), "I failed")

            msg = "Something went very wrong"
            log(logger, "fubar", msg)
            @test contains(String(take!(io)), "[fubar]:Logger.example - $msg")

            new_logger = Logger("new_logger")
        finally
            close(io)
        end
    end
    @testset "Lazy Messages" begin
        # A test utility function that gives
        # us a function to pass to the log method
        # which will execute only if the message is
        # evaluated.
        function msg_func(msg)
            inner(io) = print(io, msg)
            return inner
        end

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
                DefaultRecord,
                true
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

            set_record(logger, DefaultRecord)
            add_level(logger, "fubar", 50)

            show(io, logger)
            @test contains(String(take!(io)), "Logger(Logger.example)")

            msg = "It works!"
            Memento.info(msg_func(msg), logger)
            @test contains(String(take!(io)), "[info]:Logger.example - $msg")

            Memento.debug(msg_func("This shouldn't get logged"), logger)
            @test isempty(String(take!(io)))

            msg = "Something went very wrong"
            @test_throws ErrorException error(msg_func(msg), logger)
            @test contains(String(take!(io)), "[error]:Logger.example - $msg")

            new_logger = Logger("new_logger")
        finally
            close(io)
        end
    end
end
