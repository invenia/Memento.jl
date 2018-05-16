@testset "Memento.Test" begin
    @testset "@test_log" begin
        logger = getlogger("test_log")
        msg = "Hello!"
        setlevel!(logger, "info")
        @test_log(logger, "info", msg, info(logger, msg))

        # Partial matches
        msg = "Hello World!"
        @test_log(logger, "info", "Hello", info(logger, msg))
        @test_log(logger, "info", r"Hello*", info(logger, msg))
        @test_log(logger, "info", ("Hello", "World"), info(logger, msg))
        @test_log(logger, "info", x -> x == msg, info(logger, msg))
    end

    @testset "@test_warn" begin
        logger = getlogger("test_warn")
        msg = "Hello!"
        @test_warn(logger, msg, warn(logger, "Hello!"))
    end

    @testset "@test_throws" begin
        logger = getlogger("test_log")
        @test_throws(logger, ErrorException, error(logger, "Error!"))
    end
end
