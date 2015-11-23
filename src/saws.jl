immutable Saw
    saw_fn::Function
    _mode

    Saw(saw_fn::Function, mode=nothing) = new(saw_fn, mode)
end

call(saw::Saw, args...; kwargs...) = saw.saw_fn(args...; kwargs...)


# -------

msec_date_saw(args::Dict) = setindex!(args, now(), :date)

function fn_call_saw(args::Dict)
    # Filter out stack frames that are from Lumberjack itself.
    stack = StackTraces.remove_frames!(
        StackTraces.stacktrace(), [:fn_call_saw, :log, :info, :warn, :debug]
    )

    if isempty(stack)
        args
    else
        setindex!(args, stack[1], :lookup)
    end
end

function stacktrace_saw(args::Dict)
    # Filter out stack frames that are from Lumberjack itself.
    stack = StackTraces.remove_frames!(
        StackTraces.stacktrace(), [:stacktrace_saw, :log, :info, :warn, :debug]
    )

    setindex!(args, stack, :stacktrace)
end

# -------
