@testset "Deprecations" begin
    @testset "Memento v0.4" begin
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

    @testset "Memento v0.5" begin
        FMT_STR = "[{level}]:{name} - {msg}"
        LEVELS = Dict(
            "not_set" => 0,
            "debug" => 10,
            "info" => 20,
            "warn" => 30,
            "error" => 40,
        )

        @testset "Logger" begin
            io = IOBuffer()
            handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

            try
                # Can't properly test subsequent deprecations because of
                # https://github.com/JuliaLang/julia/issues/22043, but should be fixed by
                # https://github.com/JuliaLang/julia/pull/24490
                if VERSION < v"0.7.0-DEV.2988"
                    @suppress add_handler(getlogger(), handler, "testhandler")
                    @suppress remove_handler(getlogger(), "testhandler")
                else
                    logger = @test_warn(
                        "get_logger(name) is deprecated, use getlogger(name) instead.",
                        get_logger("Logger.example")
                    )

                    @test_warn(
                        "is_root(logger::Logger) is deprecated, use isroot(logger::Logger) instead.",
                        is_root(logger)
                    )

                    @test_warn(
                        "is_set(logger::Logger) is deprecated, use isset(logger::Logger) instead.",
                        is_set(logger)
                    )

                    @test_warn(
                        "get_level(logger::Logger) is deprecated, use getlevel(logger::Logger) instead.",
                        get_level(logger)
                    )

                    @test_warn(
                        "get_parent(logger::Logger) is deprecated, use getparent(logger::Logger) instead.",
                        getparent(logger)
                    )

                    @test_warn(
                        "set_record(logger::Logger, rec) is deprecated, use setrecord!(logger::Logger, rec) instead.",
                        setrecord!(logger, DefaultRecord)
                    )

                    @test_warn(
                        "filters(logger::Logger) is deprecated, use getfilters(logger::Logger) instead.",
                        filters(logger)
                    )

                    @test_warn(
                        "add_filter(logger::Logger, filter::Memento.Filter) is deprecated, use push!(logger::Logger, filter::Memento.Filter) instead.",
                        add_filter(logger, Memento.Filter(logger))
                    )

                    @test_warn(
                        "get_handlers(logger::Logger) is deprecated, use gethandlers(logger::Logger) instead.",
                        get_handlers(logger)
                    )

                    @test_warn(
                        "add_level(logger::Logger, level, val) is deprecated, use addlevel!(logger::Logger, level, val) instead.",
                        add_level(logger, "testlevel", 89)
                    )

                    @test_warn(
                        "set_level(logger::Logger, level) is deprecated, use setlevel!(logger::Logger, level) instead.",
                        set_level(logger, "info")
                    )

                    @test_warn(
                        "set_level(f::Function, logger::Logger, level) is deprecated, use setlevel!(f::Function, logger::Logger, level) instead.",
                        set_level(logger, "error") do
                            warn(logger, "silenced message should not be displayed")
                        end
                    )

                    @test_warn(
                        "`add_handler(logger, handler[, name])` is being deprecated in favour of `push!(logger, handler)`",
                        add_handler(getlogger(), handler, "testhandler")
                    )

                    @test_warn(
                        "`remove_handler(logger, name)` is being deprecated.",
                        remove_handler(getlogger(), "testhandler")
                    )
                end
            finally
                close(io)
            end
        end

        @testset "Handler" begin
            io = IOBuffer()

            try
                handler = DefaultHandler(io, DefaultFormatter(FMT_STR))

                logger = Logger(
                    "DefaultHandler.sample_io",
                    Dict("Buffer" => handler),
                    "info",
                    LEVELS,
                    DefaultRecord,
                    true
                )

                # Can't properly test subsequent deprecations because of
                # https://github.com/JuliaLang/julia/issues/22043, but should be fixed by
                # https://github.com/JuliaLang/julia/pull/24490
                if VERSION >= v"0.7.0-DEV.2988"
                    @test_warn(
                        "filters(handler::DefaultHandler) is deprecated, use getfilters(handler::DefaultHandler) instead.",
                        filters(handler)
                    )

                    @test_warn(
                        "add_filter(handler::DefaultHandler, filter::Memento.Filter) is deprecated, use push!(handler::DefaultHandler, filter::Memento.Filter) instead.",
                        add_filter(handler, Memento.Filter(handler))
                    )

                    @test_warn(
                        "set_level(handler::DefaultHandler, level::AbstractString) is deprecated, use setlevel!(handler::DefaultHandler, level::AbstractString) instead.",
                        set_level(handler, "info")
                    )
                end
            finally
                close(io)
            end
        end
    end
end