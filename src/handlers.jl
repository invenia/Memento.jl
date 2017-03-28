"""
`Handlers` manage formatting `Record`s and printing
the resulting `String` to an `IO` type. All `Handler`
subtypes must implement at least 1 `log(::Handler, ::Record)`
method.

NOTE: Handlers can useful if you need to special case logging behaviour
based on the `Formatter`, `IO` and/or `Record` types.
"""
abstract Handler{F<:Formatter, O<:IO}

function Memento.Filter(h::Handler)
    function level_filter(rec::Record)
        level = get(rec, :level)
        return h.levels.x[level] >= h.levels.x[h.level]
    end

    Memento.Filter(level_filter)
end

filters(handler::Handler) = Memento.Filter[]

function add_filter(handler::Handler, filter::Memento.Filter)
    push!(filters(handler), filter)
end

function log(handler::Handler, rec::Record)
    if all(f -> f(rec), filters(handler))
        emit(handler, rec)
    end
end

"""
The DefaultHandler manages any `Formatter`, `IO` and `Record`.

Fields:
- fmt: a `Formatter` for converting `Record`s to `Strings`
- io: an `IO` type for printing `String` to.
- opts: a dictionary of optional arguments such as :is_colorized and :colors
    Ex) ```Dict{Symbol, Any}(
            :is_colorized => true,
            :opts[:colors] => Dict{AbstractString, Symbol}(
                "debug" => :blue,
                "info" => :green,
                ...
            )
        )```
"""
type DefaultHandler{F<:Formatter, O<:IO} <: Handler{F, O}
    fmt::F
    io::O
    opts::Dict{Symbol, Any}
    filters::Array{Memento.Filter}
    levels::Ref{Dict{AbstractString, Int}}
    level::AbstractString
end

"""
`DefaultHandler{F<Formatter, O<:IO}(io::O, fmt::F, opts::Dict{Symbol, Any})`
creates a DefaultHandler with the specified IO type.

Args:
- io: the IO type
- fmt: the Formatter to use (default to `DefaultFormatter()`)
- opts: the optional arguments (defaults to `Dict{Symbol, Any}()`)
"""
function DefaultHandler{F<:Formatter, O<:IO}(io::O, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}())
    setup_opts(opts)
    handler = DefaultHandler(fmt, io, opts, Memento.Filter[], Ref(_log_levels), "not_set")
    push!(handler.filters, Memento.Filter(handler))
    return handler
end

"""
`DefaultHandler{F<Formatter}(filename::AbstractString, fmt::F, opts::Dict{Symbol, Any})`
creates a DefaultHandler with a IO handle to the specified filename.

Args:
- filename: the filename of a log file to write to
- fmt: the Formatter to use (default to `DefaultFormatter()`)
- opts: the optional arguments (defaults to `Dict{Symbol, Any}()`)
"""
function DefaultHandler{F<:Formatter}(filename::AbstractString, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}())
    file = open(filename, "a")
    setup_opts(opts)
    handler = DefaultHandler(fmt, file, opts, Memento.Filter[], Ref(_log_levels), "not_set")
    push!(handler.filters, Memento.Filter(handler))
    finalizer(handler, (h)->close(h.io))
    handler
end

"""
`setup_opts(opts)` sets the default :colors if `opts[:is_colorized] == true`
"""
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

filters(handler::DefaultHandler) = handler.filters

function set_level(handler::DefaultHandler, level::AbstractString)
    handler.levels.x[level]     # Throw a key error if the levels isn't in levels
    handler.level = level
end

"""
`log{F<:Formatter, O<:IO}(handler::DefaultHandler{F ,O}, rec::Record)`
logs all records with any `Formatter` and `IO` types.
"""
function emit{F<:Formatter, O<:IO}(handler::DefaultHandler{F, O}, rec::Record)
    level = get(rec, :level)
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

"""
`logs{F<:Formatter, O<:Syslog}(handler::DefaultHandler{F, O}, rec::Record)`
logs all records with any `Formatter` and a `Syslog` `IO` type.
"""
function emit{F<:Formatter, O<:Syslog}(handler::DefaultHandler{F, O}, rec::Record)
    str = format(handler.fmt, rec)
    println(handler.io, get(rec, :level), str)
    flush(handler.io)
end
