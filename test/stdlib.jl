@testset "stdlib" begin
    @testset "$VERSION" begin
        if VERSION > v"0.7.0-DEV.2980"
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
        else
            logger = getlogger("Memento")
            @test_warn(
                logger,
                "Global logging substitution is not support for julia",
                Memento.config!("info"; substitute=true)
            )
        end
    end
end