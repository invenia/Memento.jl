"""
`Record`s are used to store information about a log event including the
msg, date, level, stacktrace, etc. `Formatter`s use `Records` to format log
message strings.

TODO: Finish implementing `Record`s as specific associative types.
"""
abstract Record <: Associative

type Attribute{T}
    f::Function
    x::Nullable{T}
end

Attribute(T::Type, f::Function) = Attribute(f, Nullable{T}())
Attribute(x) = Attribute(typeof(x), () -> x)

# Base.convert(::Type{Attribute}, val::Any) = Attribute(val)

function Base.get(attr::Attribute)
    if isnull(attr.x)
        attr.x = Nullable(attr.f())
    end

    return get(attr.x)
end

"`keys(::Record)` returns all keys in the inner dict"
Base.keys(rec::Record) = keys(rec.dict)

function Base.copy{R<:Record}(rec::R)
    new_rec = R()

    for (key, val) in rec.dict
        new_rec.dict[key] = val
    end

    return new_rec
end

function Base.Dict(rec::Record)
    return map(keys(rec)) do key
        key => get(rec.dict[key])
    end |> Dict
end

"""
`getindex(::Record, key)` returns the item from the inner dict.
If the value is a zero argument function it will be executed.
"""
Base.getindex(rec::Record, key) = get(rec.dict[key])

Base.setindex!(rec::Record, val::Attribute, key::Symbol) = rec.dict[key] = val

Base.start(rec::Record) = start(rec.dict)

Base.next(rec::Record, state) = next(rec.dict, state)

Base.done(rec::Record, state) = done(rec.dict, state)

"""
`DefaultRecord` wraps a `Dict{Symbol, Any}` which stores basic logging event
information.

Info:

date: timestamp of log event
level: log level
levelnum: integer value for log level
msg: the log message itself
name: the name of the source logger
pid: the pid of where the log event occured
lookup: the top StackFrame
stacktrace: a stacktrace
"""
type DefaultRecord <: Record
    dict::Dict{Symbol, Attribute}

    DefaultRecord() = new(Dict{Symbol, Attribute}())
    DefaultRecord(args::Dict{Symbol, Any}) = new(default_attributes(args))
end

function default_attributes(args::Dict{Symbol, Any})
    time = now()
    trace = Attribute(StackTrace, get_trace)

    return Dict(
        :date => Attribute(DateTime, () -> round(time, Base.Dates.Second)),
        :level => Attribute(args[:level]),
        :levelnum => Attribute(args[:levelnum]),
        :msg => Attribute(AbstractString, get_msg(args[:msg])),
        :name => Attribute(args[:name]),
        :pid => Attribute(myid()),
        :lookup => Attribute(StackFrame, get_lookup(trace)),
        :stacktrace => trace,
    )
end

function get_trace()
    return StackTraces.remove_frames!(
        StackTraces.stacktrace(),
        [
            :DefaultRecord,
            :log,
            Symbol("#log#22"),
            :info,
            :warn,
            :debug,
            :get_trace,
            :emit,
        ]
    )
end

function get_lookup(trace::Attribute{StackTrace})
    function inner_lookup()
        if isempty(get(trace))
            return nothing
        else
            return first(get(trace))
        end
    end
end

function get_msg(msg)
    if isa(msg, AbstractString)
        return () -> msg
    else
        return msg
    end
end
