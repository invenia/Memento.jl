using Base.Test
#import Mocking: mend TODO

@testset "IO" begin
    @testset "FileRoller" begin
        levels = Dict(
            "not_set" => 0,
            "debug" => 10,
            "info" => 20,
            "warn" => 30,
            "error" => 40,
            "fubar" => 50
        )
        roller_prefix = tempname()
        info("Path to roller_prefix: $roller_prefix")
        handler = DefaultHandler(FileRoller(roller_prefix; max_sz=1024))

        logger = Logger(
            "IO.FileRoller",
            Dict("Roller" => handler),
            "debug",
            levels,
            DefaultRecord,
            true
        )

        for i = 1:100
            log(logger, "debug", "some-msg")
            log(logger, "info", "some-msg")
            log(logger, "warn", "some-msg")
            log(logger, "error", "some-msg")
            log(logger, "fubar", "some-msg")
        end

        @test ispath(dirname(roller_prefix))
        @test isfile(handler.io.filepath)
        @test dirname(roller_prefix) == dirname(handler.io.filepath)
        @test contains(handler.io.filepath, roller_prefix)
        @test handler.io.filepath != roller_prefix
        @test handler.io.filepath != "$(roller_prefix).001"
    end

    @testset "Syslog" begin
        @testset "Sample Usage" begin
            if !is_windows()
                levels = copy(Memento._log_levels)
                levels["invalid"] = 100
                handler = DefaultHandler(Syslog(:local0, "julia"), DefaultFormatter("{level}: {msg}"))

                logger = Logger(
                    "IO.Syslog",
                    Dict("Syslog" => handler),
                    "debug",
                    levels,
                    DefaultRecord,
                    true
                )

                # Syslog uses an external call to logger to do its legwork. Because the syslog itself can be
                # essentially anywhere (we might not have permission to read it, and it might not even be on
                # the same machine), we'll just make sure that the external call to logger itself is right.
                # This requires that the call to run to be overwritten has the @mock macro.
                history = []

                # Generate a alternative method of `run` which call we wish to mock
                patch = @patch run(cmd::Base.AbstractCmd, args...) = push!(history, string(cmd))

                # Apply the patch which will modify the behaviour for our test
                apply(patch) do
                    for level in keys(levels)
                        if level != "not_set"
                            if level != "invalid"
                                log(logger, level, "Message")
                                sys_level = get(Memento.ALIAS_LEVELS, Symbol(level), level)
                                @test history[end] == string(
                                    `logger -t julia -p local0.$(sys_level) "$(level): Message"`
                                )
                            else
                                @test_throws ErrorException log(logger, "invalid", "Message")
                            end
                        end
                    end
                end
            end
        end

        @testset "Construction" begin
            @test_throws ErrorException Syslog(:foobar, "julia")
            patch = @patch success(cmd::Base.AbstractCmd) = false

            apply(patch) do
                @test_throws ErrorException Syslog(:local0, "julia")
            end

            if is_windows()
                @test_throws ErrorException Syslog(:local0, "julia")
            end
        end
    end
end
