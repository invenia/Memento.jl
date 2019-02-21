import Base.CoreLogging:
    AbstractLogger,
    handle_message,
    min_enabled_level,
    shouldlog,
    global_logger,
    Debug

const LEVEL_MAP = Dict{AbstractString}
struct CoreLogger <: AbstractLogger
end

min_enabled_level(logger::CoreLogger) = Debug
shouldlog(logger::CoreLogger, arags...) = true

function handle_message(::CoreLogger, cl_level, msg, mod, group, id, filepath, line; kwargs...)
    logger = getlogger(mod)
    level = lowercase(string(cl_level))
    log(logger, logger.record(logger.name, level, getlevels(logger)[level], msg))
end

function substitute!()
    global_logger(CoreLogger())
    notice(getlogger(@__MODULE__), "Substituting global logging with Memento")
end
