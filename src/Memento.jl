VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Memento

using Mocking

import Base: show, info, warn, error, log

if !isdefined(Base, :StackTraces)
    import StackTraces
end

export log, debug, info, notice, warn, error, critical, alert, emergency,
       is_set, is_root, set_level, add_level, set_record,
       add_handler, remove_handler, remove_handlers,
       basic_config, get_logger, get_handlers, format,

       Logger,
       Record, DefaultRecord,
       Formatter, DefaultFormatter, JsonFormatter,
       Handler, DefaultHandler,
       FileRoller, Syslog


const DEFAULT_LOG_LEVEL = "warn"

global _log_levels = Dict{AbstractString, Int}(
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

end
