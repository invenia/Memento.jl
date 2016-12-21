using JSON

abstract Handler

function get_formatters(handler::Handler)
    if in(:_fmts, fieldnames(handler))
        return handler._fmts
    else
        return Vector{Formatter}()
    end
end

function add_formatter(handlers::Handler, fmt)
    if in(:_fmts, fieldnames(handler))
        append!(handler._fmts, ftm)
        return hander._fmts
    else
        return nothing
    end
end

function configure(handler::Handler; mode=nothing, fmt=Vector{Formatter})
    set_mode!(handler, mode)
    add_formatters(handler, fmt)
end

function log(handler::Handler, args::Dict)
    error("please implement `log(handler::$(typeof(handler)), args::Dict)`")
end


# -------

type SimpleHandler <: Handler
    out::IO

    # for use by the framework, will be
    # ignored if absent or set to nothing
    _mode

    _fmts::Vector{Formatter}

    function SimpleHandler(out::IO, mode=nothing, fmts=Vector{Formatter}())
        new(out, mode, fmts)
    end

    function SimpleHandler(filename::AbstractString, mode=nothing, fmts=Vector{Formatter}())
        file = open(filename, "a")
        handler = new(file, mode, fmts)
        finalizer(handler, (h)->close(h.out))
        handler
    end
end

function format(handler::SimpleHandler, l::Dict)
    return "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])"
end

function log(handler::SimpleHandler, l::Dict)
    println(handler.out, format(handler, l))
    flush(handler.out)
end

# -------

type DefaultHandler <: Handler
    out::IO
    _mode
    _fmts::Vector{Formatter}
    opts::Dict

    function DefaultHandler(out::IO, mode=nothing, opts=Dict(), fmts=Vector{Formatter}())
        setup_opts(opts)
        new(out, mode, fmts, opts)
    end

    function DefaultHandler(filename::AbstractString, mode=nothing, opts=Dict(), fmts=Vector{Formatter}())
        file = open(filename, "a")
        setup_opts(opts)
        handler = new(file, mode, fmts, opts)
        finalizer(handler, (h)->close(h.out))
        handler
    end

    function setup_opts(opts)
        if haskey(opts, :colors)
            opts[:is_colorized] = true
        elseif (!haskey(opts, :colors) && haskey(opts, :is_colorized) && opts[:is_colorized])
            # set default colors
            opts[:colors] = Dict{@compat(String),Symbol}("debug" => :cyan, "info" => :blue, "warn" => :yellow, "error" => :red)
        else
            opts[:is_colorized] = false
        end

        if (!haskey(opts, :uppercase))
            opts[:uppercase] = false
        end

        opts
    end
end

function format(handler::DefaultHandler, l::Dict)
    l = copy(l)

    date_stamp = get(l, :date, nothing)
    record = date_stamp == nothing ? "" : "$date_stamp - "

    lookup = get(l, :lookup, nothing)
    if !is(lookup, nothing)
        # lookup is a StackFrame
        name, file, line = l[:lookup].func, l[:lookup].file, l[:lookup].line
        lookup_str = "$(name)@$(basename(string(file))):$(line) - "
        record = record * lookup_str
    end

    mode = l[:mode]
    if (handler.opts[:uppercase])
        l[:mode] = uppercase(l[:mode])
    end

    record = string(record, "$(l[:mode]): $(l[:msg])")

    stacktrace = get(l, :stacktrace, nothing)
    if !is(stacktrace, nothing)
        # stacktrace is a vector of StackFrames
        record = record * string(" stack:[",
            join(
                map(f->"$(f.func)@$(basename(string(f.file))):$(f.line)", stacktrace), ", "
            ), "]"
        )
    end

    delete!(l, :date)
    delete!(l, :lookup)
    delete!(l, :stacktrace)
    delete!(l, :mode)
    delete!(l, :msg)

    for (k, v) in l
        record = string(record, " $k: $(repr(v))")
    end

    return record
end

function log(handler::DefaultHandler, l::Dict)
    mode = l[:mode]
    record = format(handler, l)

    if isa(handler.out, Syslog)
        # Syslog needs to be explicitly told what the error level is.
        println(handler.out, mode, record)
    elseif (handler.opts[:is_colorized])
        # check if color has been defined for key
        if (haskey(handler.opts[:colors], mode))
            print_with_color(handler.opts[:colors][mode], handler.out, string(record,"\n"))
        # if not, don't apply colors
        else
            println(handler.out, record)
        end
    else
        println(handler.out, record)
    end
    flush(handler.out)
end

# -------

type JsonHandler <: Handler
    out::IO
    _mode
    _fmts::Vector{Formatter}
end

JsonHandler(out::IO) = JsonHandler(out, nothing, Vector{Formatter}())

function format(handler::JsonHandler, l::Dict)
    l = copy(l)

    if haskey(l, :date)
        l[:date] = string(l[:date])
    end

    if haskey(l, :lookup)
        # lookup is a StackFrame
        l[:lookup] = Dict(
            :name => l[:lookup].func, :file => basename(string(l[:lookup].file)),
            :line => l[:lookup].line
        )
    end

    if haskey(l, :stacktrace)
        # stacktrace is a vector of StackFrames
        l[:stacktrace] = map(
            f -> Dict(:name => f.func, :file => basename(string(f.file)), :line => f.line),
            l[:stacktrace]
        )
    end

    return json(l)
end

function log(handler::JsonHandler, l::Dict)
    record = format(handler, l)

    if isa(handler.out, Syslog)
        # Syslog needs to be explicitly told what the error level is.
        println(handler.out, l[:mode], record)
    else
        println(handler.out, record)
        flush(handler.out)
    end
end
