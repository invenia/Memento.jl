
using Base.Test

const LOG_FILE = "lumberjacklog-out.log"

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_truck(Lumberjack.LumberjackTruck(LOG_FILE), "lumberjacklogfile")


# test without dates
log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")


# test with dates
add_saw(Lumberjack.msec_date_saw)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_saws()


# test with extra params
log("debug", "some-msg", @compat Dict{Any,Any}( :thing1 => "thing1" ))
log("info", "some-msg", @compat Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69 ))
log("warn", "some-msg", @compat Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3] ))
log("error", "some-msg",  @compat Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => Dict{Any,Any}( "a" => "apple" )))
log("crazy", "some-msg",  @compat Dict{Any,Any}( :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => Dict{Any,Any}( "a" => "apple" ), :thing5 => :some_symbol ))

# -------

remove_truck("lumberjacklogfile")
log_lines = readlines(open(LOG_FILE, "r"))


# test without dates
@test log_lines[1] == "debug: some-msg\n"
@test log_lines[2] == "info: some-msg\n"
@test log_lines[3] == "warn: some-msg\n"
@test log_lines[4] == "error: some-msg\n"
@test log_lines[5] == "crazy: some-msg\n"


# test with dates
date_regex = r"[\/|\-|\.|,|\s]"
@test ismatch(date_regex, log_lines[6])
@test ismatch(date_regex, log_lines[7])
@test ismatch(date_regex, log_lines[8])
@test ismatch(date_regex, log_lines[9])
@test ismatch(date_regex, log_lines[10])


# test with extra params
@test contains(log_lines[11], "debug: some-msg")
@test contains(log_lines[11], "thing1:\"thing1\"")

@test contains(log_lines[12], "info: some-msg")
@test contains(log_lines[12], "thing2:69")
@test contains(log_lines[12], "thing1:\"thing1\"")


@test contains(log_lines[13], "warn: some-msg")
@test contains(log_lines[13], "thing2:69")
@test contains(log_lines[13], "thing3:[1,2,3]")
@test contains(log_lines[13], "thing1:\"thing1\"")

@test contains(log_lines[14], "error: some-msg")
@test contains(log_lines[14], "thing2:69")
@test contains(log_lines[14], "thing3:[1,2,3]")
@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[14])
@test contains(log_lines[14], "thing1:\"thing1\"")

@test contains(log_lines[15], "crazy: some-msg")
@test contains(log_lines[15], "thing2:69")
@test contains(log_lines[15], "thing5::some_symbol")
@test contains(log_lines[15], "thing3:[1,2,3]")
@test ismatch(r"thing4:.*\"a\"=>\"apple\"", log_lines[15])
@test contains(log_lines[15], "thing1:\"thing1\"")

# clean up
@test success(`rm $LOG_FILE`)
