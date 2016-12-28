"""
`Record`s are used to store information about a log event including the
msg, date, level, stacktrace, etc. `Formatter`s use `Records` to format log
message strings.
"""
abstract Record

"`getdict(::Record)` returns the inner dict of the record "
getdict(rec::Record) = rec.dict

"`getindex(::Record, key)` returns the item from the inner dict"
Base.getindex(rec::Record, key) = rec.dict[key]

"`keys(::Record)` returns all keys in the inner dict"
Base.keys(rec::Record) = keys(rec.dict)

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
    dict::Dict{Symbol, Any}

    function DefaultRecord(args::Dict)
        trace = StackTraces.remove_frames!(
            StackTraces.stacktrace(),
            [:DefaultRecord, :log, Symbol("#log#22"), :info, :warn, :debug]
        )

        new(Dict(
            :date => round(now(), Base.Dates.Second),
            :level => args[:level],
            :levelnum => args[:levelnum],
            :msg => args[:msg],
            :name => args[:name],
            :pid => myid(),
            :lookup => isempty(trace) ? nothing : first(trace),
            :stacktrace => trace,
        ))
    end
end
