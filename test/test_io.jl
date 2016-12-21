using Base.Test
#import Mocking: mend TODO

const ROLLER_PREFIX = tempname()
println("Path to ROLLER_PREFIX: $ROLLER_PREFIX")

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_handler(Lumberjack.JsonHandler(Lumberjack.FileRoller(ROLLER_PREFIX)))

for i = 1:50000
    log("debug", "some-msg")
    log("info", "some-msg")
    log("warn", "some-msg")
    log("error", "some-msg")
    log("crazy", "some-msg")
end

@test success(`rm $ROLLER_PREFIX.0001`)
@test success(`rm $ROLLER_PREFIX.0002`)

modes = ["debug", "info", "notice", "warning", "err", "crit", "alert", "emerg"]
configure(; modes=[modes..., "invalid-syslog-level"])
Lumberjack.add_handler(DefaultHandler(Syslog(:local0, "julia")))

# Syslog uses an external call to logger to do its legwork. Because the syslog itself can be
# essentially anywhere (we might not have permission to read it, and it might not even be on
# the same machine), we'll just make sure that the external call to logger itself is right.
# This requires that the call to run to be overwritten has the @mendable macro.
history = []
# mend(run, command::Cmd -> push!(history, string(command))) do
#     for mode in modes
#         log(mode, "Message")
#         @test history[end] == string(`logger -t julia -p local0.$(mode) "$(mode): Message"`)
#     end
#
#     # Syslog only accepts certain predefined loglevels.
#     @test_throws ErrorException log("invalid-syslog-level", "Message")
# end
