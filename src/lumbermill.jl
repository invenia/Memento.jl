
type LumberMill
    timber_trucks::Dict{String, TimberTruck}
    saws::Array

    modes::Array

    function LumberMill(; timber_trucks = Dict{String, TimberTruck}(), saws = Any[], modes = ["debug", "info", "warn", "error"], curr_mode = 1)
        new(timber_trucks, saws, modes, curr_mode)
    end
end

_lumber_mill = LumberMill()

# -------

function log(lm::LumberMill, mode::String, msg::String, args::Dict)
    args[:mode] = mode
    args[:msg] = msg

    for saw in lm.saws
        args = saw(args)
    end

    for truck in lm.timber_trucks
        log(truck, args)
    end
end

log(mode::String, msg::String, args::Dict) = log(_lumber_mill, mode, msg, args)

