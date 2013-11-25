
type LumberMill
    timber_trucks::Dict{String, TimberTruck}
    saws::Array

    modes::Array

    function LumberMill(; timber_trucks = Dict{String, TimberTruck}(), saws = Any[], modes = Any[])
        lm = new(timber_trucks, saws, modes)
        configure(lm)
        lm
    end
end

# -------

function configure(lm::LumberMill; modes = ["debug", "info", "warn", "error"])
    lm.modes = modes
end

configure(; args...) = configure(_lumber_mill; args...)


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

log(mode::String, args::Dict) = log(_lumber_mill, mode, "", args)

# -------

_lumber_mill = LumberMill()

# -------
