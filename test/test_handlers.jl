using Base.Test

const LOG_FILE = tempname()
println("Path to LOG_FILE: $LOG_FILE")

#=
******************
  DefaultHandler
********************
=#
configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_handler(Lumberjack.DefaultHandler(LOG_FILE), "lumberjacklogfile")


# test without extra formatters
log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")


# test with msec_date_fmt
add_formatter(Lumberjack.msec_date_fmt)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_formatters()


# test with fn_call_fmt
add_formatter(Lumberjack.fn_call_fmt)

let
    @noinline caller(mode, msg) = log(mode, msg)
    caller("debug", "some-msg")
    caller("info", "some-msg")

    remove_formatters()


    # test with stacktrace_fmt
    add_formatter(Lumberjack.stacktrace_fmt)

    @noinline child_caller(mode, msg) = log(mode, msg)
    @noinline parent_caller(mode, msg) = child_caller(mode, msg)
    parent_caller("warn", "some-msg")
    parent_caller("error", "some-msg")

    remove_formatters()


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

remove_handler("lumberjacklogfile")
log_lines = readlines(open(LOG_FILE, "r"))
line = 0


# test without extra formatters
line += 1; @test log_lines[line] == "debug: some-msg\n"
line += 1; @test log_lines[line] == "info: some-msg\n"
line += 1; @test log_lines[line] == "warn: some-msg\n"
line += 1; @test log_lines[line] == "error: some-msg\n"
line += 1; @test log_lines[line] == "crazy: some-msg\n"


# test with msec_date_fmt
date_regex = r"[\/|\-|\.|,|\s]"
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])
line += 1; @test ismatch(date_regex, log_lines[line])


# test with fn_call_fmt
fn_regex = "caller@\\Q$(basename(@__FILE__))\\E:\\d+"
line += 1; @test ismatch(Regex(fn_regex * ".+debug: some-msg"), log_lines[line])
line += 1; @test ismatch(Regex(fn_regex * ".+info: some-msg"), log_lines[line])


# test with stacktrace_fmt
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


#=
********************
DefaultHandler (opts)
*********************
=#
const LOG_FILE_OPTS = tempname()
println("Path to LOG_FILE_OPTS: $LOG_FILE_OPTS")

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_handler(
    Lumberjack.DefaultHandler(
        LOG_FILE_OPTS, nothing,
        Dict{Any,Any}(
            :is_colorized => true,
            :uppercase => true
        )
    ), "lumberjacklogfile"
)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_handler("lumberjacklogfile")

# custom colors
add_handler(
    Lumberjack.DefaultHandler(
        LOG_FILE_OPTS, nothing,
        Dict{Any,Any}(
            :colors => Dict{Any,Any}(
                "debug" => :black,
                "info" => :red,
                "crazy" => :green
            ),
            :uppercase => true
        )
    ),
    "lumberjacklogfile"
)

log("debug", "some-msg")
log("info", "some-msg")
log("crazy", "some-msg")

remove_handler("lumberjacklogfile")

log_lines = readlines(open(LOG_FILE_OPTS, "r"))

# default colors: {"debug" => :cyan, "info" => :blue, "warn" => :yellow, "error" => :red}
# test with default colors
@test log_lines[1] == "$(Base.text_colors[:cyan])DEBUG: some-msg\n"
@test log_lines[2] == "$(Base.text_colors[:normal]Base.text_colors[:blue])INFO: some-msg\n"
@test log_lines[3] == "$(Base.text_colors[:normal]Base.text_colors[:yellow])WARN: some-msg\n"
@test log_lines[4] == "$(Base.text_colors[:normal]Base.text_colors[:red])ERROR: some-msg\n"
@test log_lines[5] == "$(Base.text_colors[:normal])CRAZY: some-msg\n"

# test with custom colors
@test log_lines[6] == "$(Base.text_colors[:black])DEBUG: some-msg\n"
@test log_lines[7] == "$(Base.text_colors[:normal]Base.text_colors[:red])INFO: some-msg\n"
@test log_lines[8] == "$(Base.text_colors[:normal]Base.text_colors[:green])CRAZY: some-msg\n"

# clean up
@test success(`rm $LOG_FILE_OPTS`)

#=
*********************
    JsonHandler
**********************
=#

const JSON_FILE = tempname()
println("Path to JSON_FILE: $JSON_FILE")

Lumberjack.add_handler(JsonHandler(open(JSON_FILE, "w")))

# test without dates
log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

# test with msec_date_fmt
add_formatter(Lumberjack.msec_date_fmt)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_formatters()

# test with fn_call_fmt
add_formatter(Lumberjack.fn_call_fmt)

let
    @noinline caller(mode, msg) = log(mode, msg)
    caller("debug", "some-msg")
    caller("info", "some-msg")

    remove_formatters()

    # test with stacktrace_fmt
    add_formatter(Lumberjack.stacktrace_fmt)

    @noinline child_caller(mode, msg) = log(mode, msg)
    @noinline parent_caller(mode, msg) = child_caller(mode, msg)
    parent_caller("warn", "some-msg")
    parent_caller("error", "some-msg")

    remove_formatters()

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
