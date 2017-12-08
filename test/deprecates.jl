@testset "Deprecations" begin
    @testset "Syslog" begin
        if Sys.isunix()
            levels = copy(Memento._log_levels)
            levels["invalid"] = 100

            # Create our DefaultHandler w/ the Syslog IO type
            handler = DefaultHandler(Memento.Syslog(), DefaultFormatter("{level}: {msg}"))

            logger = Logger(
                "Deprecated",
                Dict("Syslog" => handler),
                "debug",
                levels,
                DefaultRecord,
                true
            )

            # We just want to test that our glue code works with Syslogs.jl
            info(logger, "Hello World!")
        end
    end

    @testset "JsonFormatter" begin
        rec = DefaultRecord("Logger.example", "info", 20, "blah")

        fmt = JsonFormatter()
        result = Memento.format(fmt, rec)
        @test isa(JSON.parse(result), Dict)

        for key in [:date, :name, :level, :lookup, :stacktrace, :msg]
            @test contains(result, string(key))
        end

        @test contains(result, "blah")
    end
end