import Base.CoreLogging: 
    AbstractLogger,
    handle_message,
    min_enabled_level,
    shouldlog,
    global_logger,
    Debug

struct CoreLogger <: AbstractLogger
end

min_enabled_level(logger::CoreLogger) = Debug
shouldlog(logger::CoreLogger, arags...) = true

function handle_message(::CoreLogger, cl_level, msg, mod, group, id, filepath, line; kwargs...)
    logger = getlogger(mod)
    level = lowercase(string(cl_level))
    @sync log(logger, logger.record(logger.name, level, logger.levels[level], msg))
end

setglobal!() = global_logger(CoreLogger())