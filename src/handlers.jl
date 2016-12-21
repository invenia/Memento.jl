using JSON

abstract Handler{T<:IO}

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

function format(handler::Handler, args::Dict)
    error("please implement `format(handler::$(typeof(handler)), args::Dict)`")
end

function log(handler::Handler, args::Dict)
    record = format(handler, args)
    println(handler.io, record)
    flush(handler.io)
end

function log(handler::Handler{Syslog}, args::Dict)
    record = format(handler, l)
    println(handler.io, l[:mode], record)
    flush(handler.io)
end


# -------

type SimpleHandler{T<:IO} <: Handler{T}
    io::T
    _mode
    _fmts::Vector{Formatter}
end

function SimpleHandler{T<:IO}(io::T, mode=nothing, fmts=Vector{Formatter}())
    SimpleHandler(io, mode, fmts)
end

function SimpleHandler(filename::AbstractString, mode=nothing, fmts=Vector{Formatter}())
    file = open(filename, "a")
    handler = SimpleHandler(file, mode, fmts)
    finalizer(handler, (h)->close(h.io))
    handler
end

function format(handler::SimpleHandler, l::Dict)
    return "$(l[:remotehost]) $(l[:rfc931]) $(l[:authuser]) $(l[:date]) \"$(l[:request])\" $(l[:status]) $(l[:bytes])"
end

# -------

type DefaultHandler{T<:IO} <: Handler{T}
    io::T
    _mode
    _fmts::Vector{Formatter}
    opts::Dict
end

function DefaultHandler{T<:IO}(io::T, mode=nothing, opts=Dict(), fmts=Vector{Formatter}())
    setup_opts(opts)
    DefaultHandler(io, mode, fmts, opts)
end

function DefaultHandler(filename::AbstractString, mode=nothing, opts=Dict(), fmts=Vector{Formatter}())
    file = open(filename, "a")
    setup_opts(opts)
    handler = DefaultHandler(file, mode, fmts, opts)
    finalizer(handler, (h)->close(h.io))
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

    if handler.opts[:is_colorized] && haskey(handler.opts[:colors], mode)
        print_with_color(
            handler.opts[:colors][mode],
            handler.io, string(record,"\n")
        )
    else
        println(handler.io, record)
    end

    flush(handler.io)
end

# -------

type JsonHandler{T<:IO} <: Handler{T}
    io::T
    _mode
    _fmts::Vector{Formatter}
end

JsonHandler{T<:IO}(io::T) = JsonHandler(io, nothing, Vector{Formatter}())

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
