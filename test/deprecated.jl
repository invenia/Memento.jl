@testset "v0.4 deprecations" begin
    if Sys.isunix()
        @testset "Syslog" begin
            levels = copy(Memento._log_levels)
            levels["invalid"] = 100

            # Create our DefaultHandler w/ the Syslog IO type
            handler = @test_warn(
                "Syslog has been moved to Syslogs.jl",
                DefaultHandler(Memento.Syslog(), DefaultFormatter("{level}: {msg}"))
            )

            logger = Logger(
                "Deprecated",
                Dict("Syslog" => handler),
                "debug",
                levels,
                DefaultRecord,
                true
            )

            # We just want to test that our glue code works with Syslogs.jl
            @test_warn(
                "The custom `Memento.emit` method for Syslog IO types will not be provided in the future.",
                info(logger, "Hello World!")
            )
        end
    end

    @testset "JsonFormatter" begin
        rec = DefaultRecord("Logger.example", "info", 20, "blah")

        fmt = @test_warn(
            "JsonFormatter(aliases=Nullable()) is deprecated, use DictFormatter(aliases, JSON.json) instead.",
            JsonFormatter()
        )

        result = Memento.format(fmt, rec)
        @test isa(JSON.parse(result), Dict)

        for key in [:date, :name, :level, :lookup, :stacktrace, :msg]
            @test contains(result, string(key))
        end

        @test contains(result, "blah")
    end
end