"""
    Handler

Manage formatting `Record`s and printing
the resulting `String` to an `IO` type. All `Handler`
subtypes must implement at least 1 `log(::Handler, ::Record)`
method.

NOTE: Handlers can useful if you need to special case logging behaviour
based on the `Formatter`, `IO` and/or `Record` types.
"""
abstract type Handler{F<:Formatter, O<:IO} end

function Base.:+(handler::Handler, filter::Memento.Filter)
    push!(handler, filter)
    return handler
end

"""
    log(handler::Handler, rec::Record)

Checks the `Handler` filters and if they all pass then
`emit` the record.
"""
function log(handler::Handler, rec::Record)
    if all(f -> f(rec), getfilters(handler))
        emit(handler, rec)
    end
end

"""
    DefaultHanlder

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
mutable struct DefaultHandler{F, O} <: Handler{F, O}
    fmt::F
    io::O
    opts::Dict{Symbol, Any}
    filters::Array{Memento.Filter}
    levels::Ref{Dict{AbstractString, Int}}
    level::AbstractString
end

"""
    DefaultHandler{F, O}(io::O, fmt::F, opts::Dict{Symbol, Any}) where {F<Formatter, O<:IO}

Creates a DefaultHandler with the specified IO type.

# Arguments
* `io::IO`: the IO type
* `fmt::Formatter`: the Formatter to use (default to `DefaultFormatter()`)
* `opts::Dict`: the optional arguments (defaults to `Dict{Symbol, Any}()`)
"""
function DefaultHandler(io::O, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}()) where {F<:Formatter, O<:IO}
    setup_opts(opts)
    handler = DefaultHandler(fmt, io, opts, Memento.Filter[], Ref(_log_levels), "not_set")
    push!(handler, Memento.Filter(handler))
    return handler
end

"""
    DefaultHandler{F}(filename::AbstractString, fmt::F, opts::Dict{Symbol, Any}) where {F<Formatter}

Creates a DefaultHandler with a IO handle to the specified filename.

# Arguments
* `filename::AbstractString`: the filename of a log file to write to
* `fmt::Formatter`: the Formatter to use (default to `DefaultFormatter()`)
* `opts::Dict`: the optional arguments (defaults to `Dict{Symbol, Any}()`)
"""
function DefaultHandler(filename::AbstractString, fmt::F=DefaultFormatter(), opts=Dict{Symbol, Any}()) where {F<:Formatter}
    file = open(filename, "a")
    setup_opts(opts)
    handler = DefaultHandler(fmt, file, opts, Memento.Filter[], Ref(_log_levels), "not_set")
    push!(handler, Memento.Filter(handler))
    finalizer(handler, h -> close(h.io))
    handler
end

"""
    setup_opts(opts) -> Dict

Sets the default :colors if `opts[:is_colorized] == true`.
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

function Memento.Filter(h::DefaultHandler)
    function level_filter(rec::Record)
        level = rec[:level]
        return h.levels.x[level] >= h.levels.x[h.level]
    end

    Memento.Filter(level_filter)
end

"""
    getfilters(handler::DefaultHandler) -> Array{Filter}

Returns the filters for the handler.
"""
getfilters(handler::DefaultHandler) = handler.filters

"""
    push!(handler::DefaultHandler, filter::Memento.Filter)

Adds an new `Filter` to the handler.
"""
function Base.push!(handler::DefaultHandler, filter::Memento.Filter)
    push!(handler.filters, filter)
end

"""
    setlevel!(handler::DefaultHandler, level::AbstractString)

Sets the minimum level required to `emit` the record from the handler.
"""
function setlevel!(handler::DefaultHandler, level::AbstractString)
    handler.levels.x[level]     # Throw a key error if the levels isn't in levels
    handler.level = level
end

"""
    emit{F, O}(handler::DefaultHandler{F ,O}, rec::Record) where {F<:Formatter, O<:IO}

Handles printing any `Record` with any `Formatter` and `IO` types.
"""
function emit(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:IO}
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
