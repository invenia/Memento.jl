
using Base.Test
using Lumberjack

function reset_lumberjack()
    Lumberjack.remove_handlers()
    Lumberjack.configure()
end


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
    reset_lumberjack()
    include(abspath(file))
end
