@testset "stdlib" begin
    orig_logger = Base.CoreLogging.global_logger()

    try
        logger = getlogger("Memento")
        @test_log(
            logger,
            "notice",
            "Substituting global logging",
            Memento.config!("info"; substitute=true)
        )
    finally
        Base.CoreLogging.global_logger(orig_logger)
    end
end
