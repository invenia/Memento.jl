using Base.Test, Lumberjack
#import Mocking: mend TODO

modes = ["debug", "info", "notice", "warning", "err", "crit", "alert", "emerg"]
configure(; modes=[modes..., "invalid-syslog-level"])
Lumberjack.add_truck(LumberjackTruck(Syslog(:local0, "julia")))

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
