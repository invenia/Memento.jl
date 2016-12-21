immutable Formatter
    fmt_fn::Function
    _mode

    Formatter(fmt_fn::Function, mode=nothing) = new(fmt_fn, mode)
end

@compat (fmt::Formatter)(args...; kwargs...) = fmt.fmt_fn(args...; kwargs...)

# -------

msec_date_fmt(args::Dict) = setindex!(args, now(), :date)

function fn_call_fmt(args::Dict)
    # Filter out stack frames that are from Lumberjack itself.
    stack = StackTraces.remove_frames!(
        StackTraces.stacktrace(),
        [:fn_call_fmt, :log, @compat(Symbol("#log#22")), :info, :warn, :debug]
    )

    if isempty(stack)
        args
    else
        setindex!(args, stack[1], :lookup)
    end
end

function stacktrace_fmt(args::Dict)
    # Filter out stack frames that are from Lumberjack itself.
    stack = StackTraces.remove_frames!(
        StackTraces.stacktrace(),
        [:stacktrace_fmt, :log, @compat(Symbol("#log#22")), :info, :warn, :debug]
    )

    setindex!(args, stack, :stacktrace)
end

# -------
