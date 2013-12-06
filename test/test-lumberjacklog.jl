
using Base.Test

const LOG_FILE = "lumberjacklog-out.log"

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_truck(Lumberjack.LumberjackLog(LOG_FILE), "lumberjacklogfile")


# test without dates
log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")


# test with dates
add_saw(Lumberjack.date_saw)

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_saws()


# test with extra params
log("debug", "some-msg", { :thing1 => "thing1" })
log("info", "some-msg", { :thing1 => "thing1", :thing2 => 69 })
log("warn", "some-msg", { :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3] })
log("error", "some-msg", { :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => { "a" => "apple" } })
log("crazy", "some-msg", { :thing1 => "thing1", :thing2 => 69, :thing3 => [1, 2, 3], :thing4 => { "a" => "apple" }, :thing5 => :some_symbol })

# -------

remove_truck("lumberjacklogfile")
log_lines = readlines(open(LOG_FILE, "r"))


# test without dates
@test log_lines[1] == "debug:\"some-msg\"\n"
@test log_lines[2] == "info:\"some-msg\"\n"
@test log_lines[3] == "warn:\"some-msg\"\n"
@test log_lines[4] == "error:\"some-msg\"\n"
@test log_lines[5] == "crazy:\"some-msg\"\n"


# test with dates
date_regex = r"[\/|\-|\.|,|\s]"
@test ismatch(date_regex, log_lines[6])
@test ismatch(date_regex, log_lines[7])
@test ismatch(date_regex, log_lines[8])
@test ismatch(date_regex, log_lines[9])
@test ismatch(date_regex, log_lines[10])


# test with extra params
@test log_lines[11] == "debug:\"some-msg\" thing1:\"thing1\"\n"
@test log_lines[12] == "info:\"some-msg\" thing2:69 thing1:\"thing1\"\n"
@test log_lines[13] == "warn:\"some-msg\" thing2:69 thing3:[1,2,3] thing1:\"thing1\"\n"
@test log_lines[14] == "error:\"some-msg\" thing2:69 thing3:[1,2,3] thing4:{\"a\"=>\"apple\"} thing1:\"thing1\"\n"
@test log_lines[15] == "crazy:\"some-msg\" thing2:69 thing5::some_symbol thing3:[1,2,3] thing4:{\"a\"=>\"apple\"} thing1:\"thing1\"\n"


# clean up
@test success(`rm $LOG_FILE`)
