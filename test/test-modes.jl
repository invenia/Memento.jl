using Base.Test

const MODE_LOG_FILE = tempname()
println("Path to MODE_LOG_FILE: $MODE_LOG_FILE")

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_truck(Lumberjack.LumberjackTruck(MODE_LOG_FILE, "info"), "infotruck")
add_saw(Lumberjack.Saw(Lumberjack.fn_call_saw, "error"))

# Test limiting trucks and saws to certain log levels.
@noinline caller(mode, msg) = log(mode, msg)
caller("debug", "Message")  # Not logged.
caller("info", "Message")   # Logged.
caller("warn", "Message")   # Logged.
caller("error", "Message")  # Logged with function call.
caller("crazy", "Message")  # Logged with function call.

remove_truck("infotruck")
log_lines = readlines(open(MODE_LOG_FILE, "r"))

fn_regex = "caller@\\Q$(basename(@__FILE__))\\E:\\d+"
@test log_lines[1] == "info: Message\n"
@test log_lines[2] == "warn: Message\n"
@test ismatch(Regex(fn_regex * ".+error: Message"), log_lines[3])
@test ismatch(Regex(fn_regex * ".+crazy: Message"), log_lines[4])

# Clean up.
@test success(`rm $MODE_LOG_FILE`)
