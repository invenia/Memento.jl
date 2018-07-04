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
    Attribute(f::Function) -> Attribute{Any}
    Attribute{T}(f::Function) -> Attribute{T}

Creates an `Attribute` with the function and a `Nullable` of type `T`.
"""
Attribute{T}(f::Function) where {T} = Attribute{T}(f, Nullable{T}())
Attribute(f::Function) = Attribute{Any}(f, Nullable{Any}())

"""
    Attribute(x)

Simply wraps the value `x` in a `Nullable` and sticks that in an `Attribute` with an
empty `Function`.
"""
Attribute(x::T) where {T} = Attribute{T}(() -> x)
Attribute{T}(x::T) where {T} = Attribute{T}(() -> x)

"""
    get(attr::Attribute{T}) -> T

Run set `attr.x` to the output of `attr.f` if `attr.x` is not already set.
We then return the value stored in `attr.x`
"""
function Base.get(attr::Attribute{T}) where T
    if isnull(attr.x)
        attr.x = Nullable{T}(attr.f())
    end

    return get(attr.x)::T
end

hasfield(T::DataType, name::Symbol) = Base.fieldindex(T, name, false) > 0

"""
    Record

A dictionary-like container with `Symbol` keys used to store information about a log events
including the msg, date, level, stacktrace, etc. `Formatter`s use `Records` to format log
message strings.

You can access the properties of a `Record` by using `getindex` (ie: record[:msg]).

Subtypes of `Record` should implement `getindex(::MyRecord, ::Symbol)` and key-value pair
iteration.
"""
abstract type Record <: AbstractDict{Symbol, Any} end

"""
    getlevel(::Record) -> AbstractString

Returns the record level.
"""
getlevel(rec::Record) = rec[:level]

"""
    AttributeRecord <: Record

A `Record` which stores its properties as `Attribute`s for lazy evaluation.

Calling `getindex` or iterating will evaluate and cache the properties accessed.

Subtypes of `AttributeRecord` should implement `Memento.getattribute(::MyRecord, ::Symbol)`
instead of `getindex`.
"""
abstract type AttributeRecord <: Record end

Base.getindex(rec::Record, attr::Symbol) = getfield(rec, attr)
Base.haskey(rec::T, attr::Symbol) where {T <: Record} = hasfield(T, attr)
Base.keys(rec::T) where {T <: Record} = (fieldname(T, i) for i in 1:fieldcount(T))

Base.start(rec::Record) = 0
Base.done(rec::T, state) where {T <: Record} = state >= fieldcount(T)

function Base.next(rec::T, state::Int) where T <: Record
    new_state = state + 1
    return (fieldname(T, new_state) => getfield(rec, new_state), new_state)
end

function Base.next(rec::T, state::Int) where T <: AttributeRecord
    new_state = state + 1
    return (fieldname(T, new_state) => get(getfield(rec, new_state)), new_state)
end

"""
    getattribute(rec::AttributeRecord, attr::Symbol)
"""
getattribute(rec::AttributeRecord, attr::Symbol) = getfield(rec, attr)

Base.getindex(rec::AttributeRecord, attr::Symbol) = get(getattribute(rec, attr))


"""
    Dict(rec::Record)

Extracts the `Record` and its properties into a `Dict`

!!! warn

    On `AttributeRecord`s this may be an expensive operation, so you probably don't want to
    do this for every log record unless you're planning on using every `Attribute`.
"""
Base.Dict(::Record)


"""
    DefaultRecord <: AttributeRecord

Stores the most common logging event information.
NOTE: if you'd like more logging attributes you can:

1. add them to DefaultRecord and open a pull request if the new attributes are applicable to most applications.
2. make a custom `Record` type.

# Fields
* `date::Attribute{DateTime}`: timestamp of log event
* `level::Attribute{AbstractString}`: log level
* `levelnum::Attribute{Int}`: integer value for log level
* `msg::Attribute{AbstractString}`: the log message itself
* `name::Attribute{AbstractString}`: the name of the source logger
* `pid::Attribute{Int}`: the pid of where the log event occured
* `lookup::Attribute{StackFrame}`: the top StackFrame
* `stacktrace::Attribute{StackTrace}`: a stacktrace
"""
struct DefaultRecord <: AttributeRecord
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
    DefaultRecord(name::AbstractString, level::AbstractString, levelnum::Int, msg::AbstractString)

Takes a few initial log record arguments and creates a `DefaultRecord`.

# Arguments
* `name::AbstractString`: the name of the source logger.
* `level::AbstractString`: the log level.
* `msg::AbstractString`: the message being logged.
"""
function DefaultRecord(name::AbstractString, level::AbstractString, levelnum::Int, msg)
    time = Dates.now()
    trace = Attribute{StackTrace}(get_trace)

    DefaultRecord(
        Attribute{DateTime}(() -> round(time, Dates.Second)),
        Attribute(level),
        Attribute(levelnum),
        Attribute{AbstractString}(msg),
        Attribute(name),
        Attribute(myid()),
        Attribute{Union{StackFrame, Nothing}}(get_lookup(trace)),
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
