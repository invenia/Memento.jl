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
            handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

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
            @test length(gethandlers(logger)) == 1

            push!(logger, DefaultHandler(tempname()))
            @test length(gethandlers(logger)) == 2

            @test ispropagating(logger)
            @test setpropagating!(logger, true)

            setlevel!(logger, "info")
            @test logger.level == "info"

            push!(logger, Memento.Filter(logger))
            @test length(getfilters(logger)) == 3

            setlevel!(logger, "error") do
                @test getlevel(logger) == "error"
                Memento.warn(logger, "silenced message should not be displayed")
            end
            @test getlevel(logger) == "info"

            setrecord!(logger, DefaultRecord)

            addlevel!(logger, "fubar", 50)

            show(io, logger)
            @test occursin("Logger(Logger.example)", String(take!(io)))

            msg = "It works!"
            Memento.info(logger, msg)
            @test occursin("[info]:Logger.example - $msg", String(take!(io)))

            Memento.debug(logger, "This shouldn't get logged")
            @test isempty(String(take!(io)))

            @test_throws TestError Memento.error(logger, TestError("I failed."))
            @test occursin("I failed", String(take!(io)))

            # CompositeException
            comp = CompositeException([
                ErrorException("I am the first error"),
                ArgumentError("I am the second error"),
            ])
            @test_throws CompositeException Memento.error(logger, comp)
            output = String(take!(io))
            @test occursin("I am the first error", output)
            @test occursin("I am the second error", output)

            comp = CompositeException([
                ArgumentError("Error numero uno"),
                ErrorException("Error numero dos"),
            ])
            Memento.warn(logger, comp)
            output = String(take!(io))
            @test occursin("Error numero uno", output)
            @test occursin("Error numero dos", output)

            msg = "Something went very wrong"
            log(logger, "fubar", msg)
            @test occursin("[fubar]:Logger.example - $msg", String(take!(io)))

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
            inner() = msg
            return inner
        end

        io = IOBuffer()

        try
            handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

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
            @test length(gethandlers(logger)) == 1

            push!(logger, DefaultHandler(tempname()))
            @test length(gethandlers(logger)) == 2

            setlevel!(logger, "info")
            @test logger.level == "info"

            setrecord!(logger, DefaultRecord)
            addlevel!(logger, "fubar", 50)

            show(io, logger)
            @test occursin("Logger(Logger.example)", String(take!(io)))

            msg = "It works!"
            Memento.info(msg_func(msg), logger)
            @test occursin("[info]:Logger.example - $msg", String(take!(io)))

            Memento.debug(msg_func("This shouldn't get logged"), logger)
            @test isempty(String(take!(io)))

            msg = "Something went very wrong"
            @test_throws ErrorException error(msg_func(msg), logger)
            @test occursin("[error]:Logger.example - $msg", String(take!(io)))

            new_logger = Logger("new_logger")
        finally
            close(io)
        end
    end

    @testset "Recursive setlevel" begin
        getlogger.(("foo.bar.baz", "a.b.c"))
        foo_children = Memento.getchildren("foo")
        a_children = Memento.getchildren("a")

        @test all(==("info"), getlevel.(foo_children))
        setlevel!(getlogger("foo"), "debug"; recursive=true)

        @test all(==("debug"), getlevel.(foo_children))
        @test all(==("info"), getlevel.(a_children))

        setlevel!(getlogger("foo"), "notice"; recursive=true) do
            Memento.info(getlogger("foo"), "I shouldn't be getting printed.")
        end

        # Check that our child logging levels remain the same after
        # the above call.
        @test all(==("debug"), getlevel.(foo_children))
        @test all(==("info"), getlevel.(a_children))
    end

    @testset "Memento.config" begin
        root_logger = Memento.config!(
            "info";
            fmt="[{date} | {level} | {name}]: {msg}", colorized=false
        )

        my_logger = Memento.config!(
            getlogger("MyLogger"), "info";
            fmt="[{date} | {level} | {name}]: {msg}", colorized=false
        )

        str_logger = Memento.config!(
            "StrLogger", "info";
            fmt="[{date} | {level} | {name}]: {msg}", colorized=false
        )

        @test length(gethandlers(root_logger)) == 1
        @test length(gethandlers(my_logger)) == 1
        @test length(gethandlers(str_logger)) == 1

        @test ispropagating(my_logger)
        @test ispropagating(str_logger)

        @test getlevel(root_logger) == getlevel(my_logger) == getlevel(str_logger)

        non_prop_logger = Memento.config!(
            getlogger("NonPropLogger"), "info"; propagate=false
        )
        @test !ispropagating(non_prop_logger)

        Memento.config("notice"; recursive=true)
        @test all(l -> getlevel(l) == "notice", values(Memento._loggers))

        # reconfig
        logger = getlogger("NoReplace")
        new_logger = Memento.config("NoReplace", "info")
        @test new_logger === getlogger("NoReplace")
        @test new_logger === logger
    end

    @testset "Stacktraces" begin
        io = IOBuffer()

        try
            handler = DefaultHandler(
                io,
                DefaultFormatter(string(FMT_STR, " | {stacktrace}"))
            )

            logger = Logger(
                "Logger.example",
                Dict("Buffer" => handler),
                "info",
                LEVELS,
                DefaultRecord,
                true
            )

            # Define a test function that logs a message
            test_func() = Memento.info(logger, "Hello")
            test_func()

            msg = String(take!(io))
            @test !isempty(msg)
            @test occursin("test_func", msg)
        finally
            close(io)
        end
    end

    @testset "Don't overwrite registered logger" begin
        original_logger = Logger("new_logger")
        Memento.register(original_logger)

        logger = getlogger("new_logger")
        @test logger == original_logger

        # Makre sure registration doesn't overwrite the original registered logger
        Memento.register(Logger("new_logger"))
        logger = getlogger("new_logger")
        @test logger == original_logger
    end
end
