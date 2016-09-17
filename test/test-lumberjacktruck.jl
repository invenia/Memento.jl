
using Base.Test

const LOG_FILE = tempname()
println("Path to LOG_FILE: $LOG_FILE")

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_truck(Lumberjack.LumberjackTruck(LOG_FILE), "lumberjacklogfile")


# test without extra saws
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


    # test with kwarg params
    debug("some-msg"; thing1="thing1")
    Lumberjack.info("some-msg"; thing1="thing1", thing2=69)
    Lumberjack.warn("some-msg"; thing1="thing1", thing2=69, thing3=[1, 2, 3])
    @test_throws ErrorException Lumberjack.error("some-msg"; thing1="thing1", thing2=69, thing3=[1, 2, 3], thing4=Dict{Any,Any}("a" => "apple"))
    log("crazy", "some-msg"; thing1="thing1", thing2=69, thing3=[1, 2, 3], thing4=Dict{Any,Any}("a" => "apple"), thing5=:some_symbol)
end


# -------

remove_truck("lumberjacklogfile")
log_lines = readlines(open(LOG_FILE, "r"))
line = 0


# test without extra saws
line += 1; @test log_lines[line] == "debug: some-msg\n"
line += 1; @test log_lines[line] == "info: some-msg\n"
line += 1; @test log_lines[line] == "warn: some-msg\n"
line += 1; @test log_lines[line] == "error: some-msg\n"
line += 1; @test log_lines[line] == "crazy: some-msg\n"


# test with msec_date_saw
date_regex = r"[\/|\-|\.|,|\s]"
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])


# test with fn_call_saw
fn_regex = "caller@\\Q$(basename(@__FILE__))\\E:\\d+"
line += 1; @test ismatch(Regex(fn_regex * ".+debug: some-msg"), log_lines[line])
line += 1; @test ismatch(Regex(fn_regex * ".+info: some-msg"), log_lines[line])


# test with stacktrace_saw
stackframe = "@\\Q$(basename(@__FILE__))\\E:\\d+"
stacktrace_regex = string("child_caller", stackframe, ", parent_caller", stackframe)
line += 1; @test ismatch(Regex("warn: some-msg.+" * stacktrace_regex), log_lines[line])
line += 1; @test ismatch(Regex("error: some-msg.+" * stacktrace_regex), log_lines[line])


# test with extra params
line += 1
@test contains(log_lines[line], "debug: some-msg")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "info: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "warn: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing3: [1,2,3]")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "error: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing3: [1,2,3]")
if VERSION < v"0.5.0-"
	@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[line])
else
	@test ismatch(r"thing4:.*\"a\",\"apple\"", log_lines[line])
end
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "crazy: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing5: :some_symbol")
@test contains(log_lines[line], "thing3: [1,2,3]")
if VERSION < v"0.5.0-"
	@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[line])
else
	@test ismatch(r"thing4:.*\"a\",\"apple\"", log_lines[line])
end
@test contains(log_lines[line], "thing1: \"thing1\"")


# test with kwarg params
line += 1
@test contains(log_lines[line], "debug: some-msg")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "info: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "warn: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing3: [1,2,3]")
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "error: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing3: [1,2,3]")
if VERSION < v"0.5.0-"
	@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[line])
else
	@test ismatch(r"thing4:.*\"a\",\"apple\"", log_lines[line])
end
@test contains(log_lines[line], "thing1: \"thing1\"")

line += 1
@test contains(log_lines[line], "crazy: some-msg")
@test contains(log_lines[line], "thing2: 69")
@test contains(log_lines[line], "thing5: :some_symbol")
@test contains(log_lines[line], "thing3: [1,2,3]")
if VERSION < v"0.5.0-"
	@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[line])
else
	@test ismatch(r"thing4:.*\"a\",\"apple\"", log_lines[line])
end
@test contains(log_lines[line], "thing1: \"thing1\"")

# clean up
@test success(`rm $LOG_FILE`)
