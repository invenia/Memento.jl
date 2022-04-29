using Base.CoreLogging:
    CoreLogging,
    AbstractLogger,
    LogLevel,
    handle_message,
    min_enabled_level,
    shouldlog,
    global_logger

struct BaseLogger <: AbstractLogger
    min_level::LogLevel
end

CoreLogging.min_enabled_level(logger::BaseLogger) = logger.min_level
CoreLogging.shouldlog(logger::BaseLogger, args...) = true
CoreLogging.catch_exceptions(logger::BaseLogger) = false

function CoreLogging.handle_message(
    ::BaseLogger,
    cl_level,
    msg,
    mod,
    group,
    id,
    filepath,
    line;
    kwargs...
)
    logger = getlogger(mod)
    level = lowercase(string(cl_level))
    log(logger, logger.record(logger.name, level, getlevels(logger)[level], msg))
end

function substitute!(level::LogLevel=min_enabled_level(global_logger()))
    global_logger(BaseLogger(level))
    notice(getlogger(@__MODULE__), "Substituting global logging with Memento")
end

# `getlogger` dispatch to reroute stdlib messages with `mod=nothing` to the root logger, 
# similar to calling `getlogger` with no arguments.
getlogger(::Nothing) = getlogger()
