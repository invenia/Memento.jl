
using Base.Test
using Lumberjack


cd(dirname(@__FILE__))
files = [
    "io.jl",
    "records.jl",
    "formatters.jl",
    "handlers.jl",
    "loggers.jl",
]

# Run each file in the test directory that looks like "test-XXXX.jl"
# Test files should assume the global lumber mill has been reset
for file in files
    Lumberjack.reset!()
    include(abspath(file))
end
