using Base.Test, JSON

const JSON_FILE = tempname()
println("Path to JSON_FILE: $JSON_FILE")

Lumberjack.add_truck(JsonTruck(open(JSON_FILE, "w")))

# test without dates
log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

# test with msec_date_saw
add_saw(Lumberjack.msec_date_saw)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_saws()

# test with fn_call_saw
add_saw(Lumberjack.fn_call_saw)

let
    @noinline caller(mode, msg) = log(mode, msg)
    caller("debug", "some-msg")
    caller("info", "some-msg")

    remove_saws()

    # test with stacktrace_saw
    add_saw(Lumberjack.stacktrace_saw)

    @noinline child_caller(mode, msg) = log(mode, msg)
    @noinline parent_caller(mode, msg) = child_caller(mode, msg)
    parent_caller("warn", "some-msg")
    parent_caller("error", "some-msg")

    remove_saws()

    # test with extra params
    log("debug", "some-msg", Dict{Any,Any}( :thing1 => "thing1" ))
    log("info", "some-msg", Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69 ))
    log("warn", "some-msg", Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3] ))
    log("error", "some-msg", Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => Dict{Any,Any}( "a" => "apple" )))
    log("crazy", "some-msg", Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => Dict{Any,Any}( "a" => "apple" ), :thing5 => :some_symbol ))
end

js = JSON.parse("[$(join(readlines(open(JSON_FILE)), ','))]")

for j in js
    @test j["msg"] == "some-msg"
end

for i = 6:10
    @test haskey(js[i], "date")
end

for i = 11:12
    @test js[i]["lookup"]["name"] == "caller"
end

for i = 13:14
    @test js[i]["stacktrace"][1]["name"] == "child_caller"
    @test js[i]["stacktrace"][1]["file"] == basename(string(@__FILE__))
    @test js[i]["stacktrace"][2]["name"] == "parent_caller"
    @test js[i]["stacktrace"][2]["file"] == basename(string(@__FILE__))
end

for i = 15:19
    @test js[i]["thing1"] == "thing1"
end

for i = 16:19
    @test js[i]["thing2"] == 69
end

for i = 17:19
    @test js[i]["thing3"] == [1, 2, 3]
end

for i = 18:19
    @test js[i]["thing4"]["a"] == "apple"
end

@test js[19]["thing5"] == "some_symbol"

# clean up
@test success(`rm $JSON_FILE`)
