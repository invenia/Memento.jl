
type Attribute{T}
    f::Function
    x::Nullable{T}
end

Attribute(T::Type, f::Function) = Attribute(f, Nullable{T}())
Attribute(x) = Attribute(typeof(x), () -> x)

function Base.get(attr::Attribute)
    if isnull(attr.x)
        attr.x = Nullable(attr.f())
    end

    return get(attr.x)
end

"""
`Record`s are used to store information about a log event including the
msg, date, level, stacktrace, etc. `Formatter`s use `Records` to format log
message strings.

TODO: Finish implementing `Record`s as specific associative types.
"""
abstract Record

Base.get(rec::Record, attr::Symbol) = get(getfield(rec, attr))

function Base.Dict(rec::Record)
    return map(fieldnames(rec)) do key
        key => get(rec, key)
    end |> Dict
end


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
immutable DefaultRecord <: Record
    date::Attribute
    level::Attribute
    levelnum::Attribute
    msg::Attribute
    name::Attribute
    pid::Attribute
    lookup::Attribute
    stacktrace::Attribute
end

function DefaultRecord(args::Dict{Symbol, Any})
    time = now()
    trace = Attribute(StackTrace, get_trace)

    DefaultRecord(
        Attribute(DateTime, () -> round(time, Base.Dates.Second)),
        Attribute(args[:level]),
        Attribute(args[:levelnum]),
        Attribute(AbstractString, get_msg(args[:msg])),
        Attribute(args[:name]),
        Attribute(myid()),
        Attribute(StackFrame, get_lookup(trace)),
        trace,
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
