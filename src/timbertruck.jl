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

    CommonLogTruck(out::IO, mode = nothing) = new(out, mode)

    function CommonLogTruck(filename::String, mode = nothing)
        file = open(filename, "a")
        truck = new(file, mode)
        finalizer(truck, (t)->close(t.out))
        truck
    end
end

function log(truck::CommonLogTruck, l::Dict)
    println(truck.out, "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])")
    flush(truck.out)
end

# -------

type LumberjackTruck <: TimberTruck
    out::IO
    _mode
    opts::Dict

    function LumberjackTruck(out::IO, mode = nothing, opts = Dict())
        setup_opts(opts)
        new(out, mode, opts)
    end

    LumberjackTruck(out::IO, mode = nothing) = new(out, mode)

    function LumberjackTruck(filename::String, mode = nothing, opts = Dict())
        file = open(filename, "a")
        setup_opts(opts)
        truck = new(file, mode, opts)
        finalizer(truck, (t)->close(t.out))
        truck
    end

    function setup_opts(opts)
        if haskey(opts, :colors)
            opts[:is_colorized] = true
        elseif (!haskey(opts, :colors) && haskey(opts, :is_colorized) && opts[:is_colorized])
            # set default colors
            opts[:colors] = {"debug" => :cyan, "info" => :blue, "warn" => :yellow, "error" => :red}
        else
            opts[:is_colorized] = false
        end

        if (!haskey(opts, :uppercase))
            opts[:uppercase] = false
        end

        opts
    end
end

function log(truck::LumberjackTruck, l::Dict)
    l = copy(l)

    date_stamp = get(l, :date, nothing)
    record = date_stamp == nothing ? "" : "$date_stamp - "

    lookup = get(l, :lookup, nothing)
    if !is(lookup,nothing)
        # lookup is a tuple
        func , fname, linenum = lookup
        lookup_str = "$(string(func))@$(basename(string(fname))):$(linenum) - "
        record = record*lookup_str
    end

    mode = l[:mode]

    if (truck.opts[:uppercase])
        l[:mode] = uppercase(l[:mode])
    end

    record = string(record, "$(l[:mode]): $(l[:msg])")

    delete!(l, :date)
    delete!(l, :lookup)
    delete!(l, :mode)
    delete!(l, :msg)

    for (k, v) in l
        record = string(record, " $k:$(repr(v))")
    end


    if (truck.opts[:is_colorized])
        # check if color has been defined for key
        if (haskey(truck.opts[:colors], mode))
            print_with_color(truck.opts[:colors][mode], truck.out, string(record,"\n"))
        # if not, don't apply colors
        else
            println(truck.out, record)
        end
    else
        println(truck.out, record)
    end
    flush(truck.out)
end

# -------
