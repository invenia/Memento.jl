using Base.Test
#import Mocking: mend TODO

@testset "IO" begin
    @testset "FileRoller" begin
        levels = Dict(
            :debug => 10,
            :info => 20,
            :warn => 30,
            :error => 40,
            :fubar => 50
        )
        roller_prefix = tempname()
        info("Path to roller_prefix: $roller_prefix")
        handler = DefaultHandler(FileRoller(roller_prefix; max_sz=1028))

        logger = Logger(
            "IO.FileRoller",
            Dict("Roller" => handler),
            :debug,
            levels,
            default_record
        )

        for i = 1:300
            log(logger, :debug, "some-msg")
            log(logger, :info, "some-msg")
            log(logger, :warn, "some-msg")
            log(logger, :error, "some-msg")
            log(logger, :fubar, "some-msg")
        end

        @test success(`rm $roller_prefix.0001`)
        @test success(`rm $roller_prefix.0002`)
    end

    @testset "Syslog" begin
        levels = copy(Lumberjack.DEFAULT_LOG_LEVELS)
        levels[:invalid] = 100
        handler = DefaultHandler(Syslog(:local0, "julia"))

        logger = Logger(
            "IO.Syslog",
            Dict("Syslog" => handler),
            :debug,
            levels,
            default_record
        )

        # Syslog uses an external call to logger to do its legwork. Because the syslog itself can be
        # essentially anywhere (we might not have permission to read it, and it might not even be on
        # the same machine), we'll just make sure that the external call to logger itself is right.
        # This requires that the call to run to be overwritten has the @mendable macro.
        history = []
        # mend(run, command::Cmd -> push!(history, string(command))) do
        #     for mode in modes
        #         log(mode, "Message")
        #         @test history[end] == string(`logger -t julia -p local0.$(mode) "$(mode): Message"`)
        #     end
        #
        #     # Syslog only accepts certain predefined loglevels.
        #     @test_throws ErrorException log("invalid-syslog-level", "Message")
        # end
    end
end
