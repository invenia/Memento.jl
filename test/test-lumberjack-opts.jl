using Base.Test

const LOG_FILE_OPTS = "lumberjacklog-out-opts.log"

configure(; modes = ["debug", "info", "warn", "error", "crazy"])

add_truck(Lumberjack.LumberjackTruck(LOG_FILE_OPTS, nothing, {:is_colorized => true, :uppercase => true}), "colorlumberjacklogfile")

log("debug", "some-msg")
log("info", "some-msg")
log("warn", "some-msg")
log("error", "some-msg")
log("crazy", "some-msg")

remove_truck("optslumberjacklogfile")

# custom colors
add_truck(Lumberjack.LumberjackTruck(LOG_FILE_OPTS, nothing, {:colors => {"debug" => :black, "info" => :red, "crazy" => :green}, :uppercase => true}), "optslumberjacklogfile")

log("debug", "some-msg")
log("info", "some-msg")
log("crazy", "some-msg")

remove_truck("optslumberjacklogfile")

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
