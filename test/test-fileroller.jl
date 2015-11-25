using Base.Test

const ROLLER_PREFIX = tempname()
println("Path to ROLLER_PREFIX: $ROLLER_PREFIX")

configure(; modes = ["debug", "info", "warn", "error", "crazy"])
add_truck(Lumberjack.JsonTruck(Lumberjack.FileRoller(ROLLER_PREFIX)))

for i = 1:50000
    log("debug", "some-msg")
    log("info", "some-msg")
    log("warn", "some-msg")
    log("error", "some-msg")
    log("crazy", "some-msg")
end

@test success(`rm $ROLLER_PREFIX.0001`)
@test success(`rm $ROLLER_PREFIX.0002`)
