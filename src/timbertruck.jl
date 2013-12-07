
abstract TimberTruck

log(t::TimberTruck, a::Dict) = error("please implement `log(truck::$(typeof(t)), args::Dict)`")


function configure(t::TimberTruck; mode = nothing)
    !in(:_mode, names(t)) && return
    t._mode = mode
end


# -------

type CommonLogTruck <: TimberTruck
    out::IO

    # for use by the framework, will be
    # ignored if absent or set to nothing
    _mode
end

function log(truck::CommonLogTruck, l::Dict)
    println(truck.out, "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])")
end

# -------

type LumberjackTruck <: TimberTruck
    out::IO

    _mode

    LumberjackTruck(out::IO, mode = nothing) = new(out, mode)
    function LumberjackTruck(filename::String, mode = nothing)
        file = open(filename, "a")
        truck = new(file, mode)
        finalizer(truck, (t)->close(t.out))
        truck
    end
end

function log(truck::LumberjackTruck, l::Dict)
    l = copy(l)

    date_stamp = get(l, :date, nothing)
    record = date_stamp == nothing ? "" : "$date_stamp - "

    record = string(record, "$(l[:mode]):$(repr(l[:msg]))")
    delete!(l, :date)
    delete!(l, :mode)
    delete!(l, :msg)

    for (k, v) in l
        record = string(record, " $k:$(repr(v))")
    end

    println(truck.out, record)
    flush(truck.out)
end

# -------
