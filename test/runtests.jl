

require("../src/Lumberjack.jl")

l = Lumberjack.CommonLog("127.0.0.1", "bob", "bigbob", "GET /hotdog", 200, 42)

show(l)