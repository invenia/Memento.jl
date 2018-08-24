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
        @info("Path to roller_prefix: $roller_prefix")
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
        @test occursin(roller_prefix, handler.io.filepath)
        @test handler.io.filepath != roller_prefix
        @test handler.io.filepath != "$(roller_prefix).001"
    end
end
