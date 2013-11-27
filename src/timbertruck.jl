
abstract TimberTruck

log(t::TimberTruck, a::Dict) = error("please implement `log(truck::$(typeof(t)), args::Dict)`")

# -------

type CommonLog <: TimberTruck
    out::IO

    # for use by the framework, will be
    # ignored if absent or set to nothing
    _mode
    _scope
end

function log(truck::CommonLog, l::Dict)
    println(truck.out, "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])")
end

# -------

type LumberjackLog <: TimberTruck
    out::IO

    _mode
    _scope
end

function log(truck::LumberjackLog, l::Dict)
    record = "$(l[:date]) $(l[:mode]): \"$(l[:msg])\""
    delete!(l, :date)
    delete!(l, :mode)
    delete!(l, :msg)

    for (k, v) in l
        record = string(record, " $(k):$(v)")
    end

    println(truck.out, record)
end

# -------
