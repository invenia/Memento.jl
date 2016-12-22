
using Base.Test
using Lumberjack
using JSON

cd(dirname(@__FILE__))
files = [
    "io.jl",
    "records.jl",
    "formatters.jl",
    "handlers.jl",
    "loggers.jl",
]

@testset "Logging" begin
    @testset "Sample Usage" begin
        basic_config("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
        logger1 = get_logger(current_module())
        debug(logger1, "Something that won't get logged.")
        info(logger1, "Something you might want to know.")
        warn(logger1, "This might cause an error.")
        warn(logger1, ErrorException("A caught exception that we want to log as a warning."))
        @test_throws ErrorException error(logger1, "Something that should throw an error.")
        logger2 = get_logger("Pkg.Foo.Bar")
    end
end


# Run each file in the test directory that looks like "test-XXXX.jl"
# Test files should assume the global lumber mill has been reset
for file in files
    Lumberjack.reset!()
    include(abspath(file))
end
