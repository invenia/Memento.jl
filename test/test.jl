@testset "Memento.Test" begin
    @testset "@test_log" begin
        logger = getlogger("test_log")
        setlevel!(logger, "info")
        @test_log(logger, "info", "Hello!", info(logger, "Hello!"))
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
