abstract Handler{F<:Formatter, O<:IO}

type DefaultHandler{F<:Formatter, O<:IO} <: Handler{F, O}
    fmt::F
    io::O
    opts::Dict{Symbol, Any}
end

function DefaultHandler{F<:Formatter, O<:IO}(io::O, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}())
    setup_opts(opts)
    DefaultHandler(fmt, io, opts)
end

function DefaultHandler{F<:Formatter}(filename::AbstractString, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}())
    file = open(filename, "a")
    setup_opts(opts)
    handler = DefaultHandler(fmt, file, opts)
    finalizer(handler, (h)->close(h.io))
    handler
end

function setup_opts(opts)
    if haskey(opts, :colors)
        opts[:is_colorized] = true
    elseif (!haskey(opts, :colors) && haskey(opts, :is_colorized) && opts[:is_colorized])
        # set default colors
        opts[:colors] = Dict{AbstractString, Symbol}(
            "debug" => :blue,
            "info" => :green,
            "notice" => :cyan,
            "warn" => :magenta,
            "error" => :red,
            "critical" => :yellow,
            "alert" => :white,
            "emergency" => :black,
        )
    else
        opts[:is_colorized] = false
    end

    opts
end

function log{F<:Formatter, O<:IO}(handler::DefaultHandler{F, O}, rec::Record)
    level = rec[:level]
    str = format(handler.fmt, rec)

    if handler.opts[:is_colorized] && haskey(handler.opts[:colors], level)
        print_with_color(
            handler.opts[:colors][level],
            handler.io,
            string(str,"\n")
        )
    else
        println(handler.io, str)
    end

    flush(handler.io)
end

function log{F<:Formatter, O<:Syslog}(handler::DefaultHandler{F, O}, rec::Record)
    str = format(handler.fmt, rec)
    println(handler.io, rec[:level], str)
    flush(handler.io)
end
