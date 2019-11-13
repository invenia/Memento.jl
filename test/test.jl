@testset "Memento.TestUtils" begin
    @testset "@test_log" begin
        logger = getlogger("test_log")
        msg = "Hello!"
        setlevel!(logger, "info")
        @test_log(logger, "info", msg, Memento.info(logger, msg))

        # Partial matches
        msg = "Hello World!"
        @test_log(logger, "info", "Hello", Memento.info(logger, msg))
        @test_log(logger, "info", r"Hello*", Memento.info(logger, msg))
        @test_log(logger, "info", ("Hello", "World"), Memento.info(logger, msg))
        @test_log(logger, "info", x -> x == msg, Memento.info(logger, msg))
    end

    @testset "@test_nolog" begin
        logger = getlogger("test_nolog")
        setlevel!(logger, "info")

        msg = "Hello!"
        different_msg = "Goodbye"

        @test_nolog(logger, "info", msg, nothing)
        @test_nolog(logger, "info", msg, Memento.debug(logger, msg))
        @test_nolog(logger, "info", msg, Memento.info(logger, different_msg))
        @test_nolog(logger, "info", msg, Memento.warn(logger, different_msg))
        @test_nolog(logger, "info", r".*foo.*", Memento.info(logger, "baz"))
    end

    @testset "@test_warn" begin
        logger = getlogger("test_warn")
        msg = "Hello!"
        @test_warn(logger, msg, Memento.warn(logger, "Hello!"))
    end

    @testset "@test_throws" begin
        logger = getlogger("test_log")
        @test_throws(logger, ErrorException, error(logger, "Error!"))
    end
end
