
type LumberMill
    timber_trucks::Dict{Any, TimberTruck}
    saws::Array

    modes::Array

    function LumberMill(; timber_trucks = Dict{Any, TimberTruck}(), saws = Any[], modes = Any[])
        lm = new(timber_trucks, saws, modes)

        # defaults
        configure(lm)
        add_saw(lm, date_saw)
        add_truck(lm, LumberjackTruck(STDOUT, nothing, {:is_colorized => true}), "console")

        lm
    end
end

# -------

function configure(lm::LumberMill;
                   modes = ["debug", "info", "warn", "error"],
                   trucks = Dict{Any, Dict}())

    lm.modes = modes

    for (truck, settings) in trucks
        configure(lm.timber_trucks[truck]; settings...)
    end
end

configure(; args...) = configure(_lumber_mill; args...)


function log(lm::LumberMill, mode::String, msg::String, args::Dict = Dict())
    args[:mode] = mode
    args[:msg] = msg

    for saw in lm.saws
        args = saw(args)
    end

    for (truck_name, truck) in lm.timber_trucks
        if (in(:_mode, names(truck))
            && truck._mode != nothing
            && get_mode_index(lm, mode) < get_mode_index(lm, truck._mode))

            continue
        end

        log(truck, args)
    end
end

log(mode::String, msg::String, args::Dict = Dict()) = log(_lumber_mill, mode, msg, args)

log(mode::String, args::Dict = Dict()) = log(_lumber_mill, mode, "", args)


debug(lm::LumberMill, msg::String, args::Dict = Dict()) = log(lm, "debug", msg, args)

debug(msg::String, args::Dict) = debug(_lumber_mill, msg, args)

debug(msg::String...) = debug(_lumber_mill, string(msg...))


info(lm::LumberMill, msg::String, args::Dict = Dict()) = log(lm, "info", msg, args)

info(msg::String, args::Dict) = info(_lumber_mill, msg, args)

info(msg::String...; prefix = "info: ") = info(_lumber_mill, string(msg...))


warn(lm::LumberMill, msg::String, args::Dict = Dict()) = log(lm, "warn", msg, args)

warn(msg::String, args::Dict) = warn(_lumber_mill, msg, args)

function warn(msg::String...; prefix="warning: ", once = false, key = nothing, bt = nothing)
    str = chomp(bytestring(msg...))

    if once
        if key === nothing
            key = str
        end

        (key in Base.have_warned) && return
        push!(Base.have_warned, key)
    end

    warn(_lumber_mill, str, bt !== nothing ? {:backtrace => sprint(show_backtrace, bt)} : Dict())
end

warn(err::Exception; prefix = "error: ", kw...) =
    warn(sprint(io->showerror(io,err)), prefix = prefix; kw...)


function error(lm::LumberMill, msg::String, args::Dict = Dict())
    exception_msg = copy(msg)
    length(args) > 0 && (exception_msg *= " $args")

    log(lm, "error", msg, args)

    throw(ErrorException(exception_msg))
end

error(msg::String, args::Dict) = error(_lumber_mill, msg, args)

error(msg...) = error(_lumber_mill, string(msg...))


function add_saw(lm::LumberMill, saw_fn::Function, index = length(lm.saws)+1)
    insert!(lm.saws, index, saw_fn)
end

add_saw(saw_fn::Function, index = length(_lumber_mill.saws)+1) = add_saw(_lumber_mill, saw_fn, index)


function remove_saw(lm::LumberMill, index = length(lm.saws))
    splice!(lm.saws, index)
end

remove_saw(index = length(_lumber_mill.saws)) = remove_saw(_lumber_mill, index)


function remove_saws(lm::LumberMill = _lumber_mill)
    empty!(lm.saws)
end


function add_truck(lm::LumberMill, truck::TimberTruck, name = string(UUID.v4()))
    lm.timber_trucks[name] = truck
end

add_truck(truck::TimberTruck, name = string(UUID.v4())) = add_truck(_lumber_mill, truck, name)


function remove_truck(lm::LumberMill, name)
    delete!(lm.timber_trucks, name)
end

remove_truck(name) = remove_truck(_lumber_mill, name)


function remove_trucks(lm::LumberMill = _lumber_mill)
    empty!(lm.timber_trucks)
end

# -------

function get_mode_index(lm::LumberMill, mode)
    index = findfirst(lm.modes, mode)
    index > 0 ? index : length(lm.modes) + 1
end

# -------

_lumber_mill = LumberMill()

# -------
