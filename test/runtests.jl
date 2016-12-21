
using Lumberjack

function reset_lumberjack()
    Lumberjack.remove_handlers()
    Lumberjack.remove_formatters()
    Lumberjack.configure()
end


cd(dirname(@__FILE__))
files = readdir()

# Run each file in the test directory that looks like "test-XXXX.jl"
# Test files should assume the global lumber mill has been reset
for file in files
    !(startswith(file, "test_") && endswith(file, ".jl")) && continue

    reset_lumberjack()
    include(abspath(file))
end
