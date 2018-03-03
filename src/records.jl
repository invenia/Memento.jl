"""
    Attribute

An `Attribute` represents a lazily evaluated field in a log `Record`.

# Fields
* `f::Function`: A function to evaluate in order to get a value if one is not set.
* `x::Nullable`: A value that may or may not exist yet.
"""
mutable struct Attribute{T}
    f::Function
    x::Nullable{T}
end

"""
    Attribute(T::Type, f::Function)

Creates an `Attribute` with the function and a `Nullable` of type `T`.
"""
Attribute(T::Type, f::Function) = Attribute(f, Nullable{T}())

"""
    Attribute(x)

Simply wraps the value `x` in a `Nullable` and sticks that in an `Attribute` with an
empty `Function`.
"""
Attribute(x) = Attribute(typeof(x), () -> x)

"""
    get(attr::Attribute{T}) -> T

Run set `attr.x` to the output of `attr.f` if `attr.x` is not already set.
We then return the value stored in `attr.x`
"""
function Base.get(attr::Attribute)
    if isnull(attr.x)
        attr.x = Nullable(attr.f())
    end

    return get(attr.x)
end

"""
    Record

Are an `Attribute` container used to store information about a log events including the
msg, date, level, stacktrace, etc. `Formatter`s use `Records` to format log
message strings.

NOTE: you should access `Attribute`s in a `Record` by using `getindex` (ie: record[:msg])
as this will correctly extract the value from the `Attribute` container.
"""
abstract type Record end

Base.getindex(rec::Record, attr::Symbol) = get(getfield(rec, attr))

"""
    Dict(rec::Record)

Extracts the `Record` and its `Attribute`s into a `Dict`
NOTE: This may be an expensive operations, so you probably don't want to do this for every
log record unless you're planning on using every `Attribute`.
"""
function Base.Dict(rec::Record)
    return map(fieldnames(typeof(rec))) do key
        key => rec[key]
    end |> Dict
end


"""
    DefaultRecord

Stores the most common logging event information.
NOTE: if you'd like more logging attributes you can:

1. add them to DefaultRecord and open a pull request if the new attributes are applicable to most applications.
2. make a custom `Record` type.

# Fields
* `date::Attribute{DateTime}`: timestamp of log event
* `level::Attribute{Symbol}`: log level
* `levelnum::Attribute{Int}`: integer value for log level
* `msg::Attribute{AbstractString}`: the log message itself
* `name::Attribute{AbstractString}`: the name of the source logger
* `pid::Attribute{Int}`: the pid of where the log event occured
* `lookup::Attribute{StackFrame}`: the top StackFrame
* `stacktrace::Attribute{StackTrace}`: a stacktrace
"""
struct DefaultRecord <: Record
    date::Attribute
    level::Attribute
    levelnum::Attribute
    msg::Attribute
    name::Attribute
    pid::Attribute
    lookup::Attribute
    stacktrace::Attribute
end

"""
    DefaultRecord(name::AbstractString, level::AbstractString, msg::AbstractString)

Takes a few initial log record arguments and creates a `DefaultRecord`.

# Arguments
* `name::AbstractString`: the name of the source logger.
* `level::AbstractString`: the log level.
* `msg::AbstractString`: the message being logged.
"""
function DefaultRecord(name::AbstractString, level::AbstractString, levelnum::Int, msg)
    time = Dates.now()
    trace = Attribute(StackTrace, get_trace)

    DefaultRecord(
        Attribute(DateTime, () -> round(time, Dates.Second)),
        Attribute(level),
        Attribute(levelnum),
        Attribute(AbstractString, get_msg(msg)),
        Attribute(name),
        Attribute(myid()),
        Attribute(Union{StackFrame, Nothing}, get_lookup(trace)),
        trace,
    )
end

"""
    get_trace()

Returns the `StackTrace` with `StackFrame`s from the `Memento` module filtered out.
"""
function get_trace()
    trace = StackTraces.stacktrace()
    return filter!(trace) do frame
        !Base.StackTraces.from(frame, Memento)
    end
end

"""
    get_lookup(trace::Attribute{StackTrace})

Returns the top `StackFrame` for `trace` if it isn't empty.
"""
function get_lookup(trace::Attribute{StackTrace})
    inner() = isempty(get(trace)) ? nothing : first(get(trace))
    return inner
end

"""
    get_msg(msg) -> Function

Wraps `msg` in a function if it is a String.
"""
function get_msg(msg)
    if isa(msg, AbstractString)
        return () -> msg
    else
        return msg
    end
end
