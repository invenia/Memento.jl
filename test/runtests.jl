
using Lumberjack

function reset_lumberjack()
    Lumberjack.remove_trucks()
    Lumberjack.remove_saws()
    Lumberjack.configure()
end


cd(dirname(@__FILE__))
files = readdir()

# Run each file in the test directory that looks like "test-XXXX.jl"
# Test files should assume the global lumber mill has been reset
for file in files
    !(startswith(file, "test-") && endswith(file, ".jl")) && continue

    reset_lumberjack()
    include(abspath(file))
end
