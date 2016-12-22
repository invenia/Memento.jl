VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Lumberjack

import Base.show, Base.info, Base.log, Compat.@compat
#import Mocking: @mendable # TODO - figure out how to use Mocking on 0.5

if !isdefined(Base, :StackTraces)
    import StackTraces
end

# To avoid warnings, intentionally do not import:
# Base.error, Base.warn, Base.info

export log, debug, info, notice, warn, error, critical, alert, emergency,
       set_level, add_level, set_record,
       add_handler, remove_handler, remove_handlers,
       basic_config, get_logger, get_handlers, default_record, format,

       Logger,
       Record, DefaultRecord,
       Formatter, DefaultFormatter, JsonFormatter,
       Handler, DefaultHandler,
       FileRoller, Syslog


const DEFAULT_LOG_LEVEL = "warn"

const DEFAULT_LOG_LEVELS = Dict{AbstractString, Int}(
    "not_set" => 0,
    "debug" => 10,
    "info" => 20,
    "notice" => 30,
    "warn" => 40,
    "error" => 50,
    "critical" => 50,
    "alert" => 60,
    "emergency" => 70
)

global _loggers

include("io.jl")
include("records.jl")
include("formatters.jl")
include("handlers.jl")
include("loggers.jl")

function __init__()
    global _loggers = Dict{Any, Logger}(
        "root" => Logger("root"),
    )
end

function basic_config(level::AbstractString; fmt::AbstractString=DEFAULT_FMT_STRING, colorized=true)
    _loggers["root"] = Logger("root"; level=level)
    add_handler(
        _loggers["root"],
        DefaultHandler(
            STDOUT,
            DefaultFormatter(fmt),
            Dict{Symbol, Any}(:is_colorized => colorized)
        ),
        "console"
    )

    return _loggers["root"]
end

function reset!()
    empty!(_loggers)
    Lumberjack.__init__()
end

function get_parent(name)
    tokenized = split(name, '.')

    if length(tokenized) == 1
        return get_logger("root")
    elseif length(tokenized) == 2
        return get_logger(tokenized[1])
    else
        return get_logger(join(tokenized[1:end-1], '.'))
    end
end

get_logger(name::Module) = get_logger("$name")

function get_logger(name="root")
    logger_name = name == "" ? "root" : name

    if !(haskey(_loggers, logger_name))
        parent = get_parent(logger_name)
        _loggers[logger_name] = Logger(
            logger_name,
            parent.handlers,
            parent.level,
            parent.levels,
            parent.record
        )
    end

    return _loggers[logger_name]
end

end
