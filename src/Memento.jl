__precompile__()

module Memento

using Mocking
using Compat

import Base: show, info, warn, error, log

export log, debug, info, notice, warn, error, critical, alert, emergency,
       is_set, is_root, set_level, add_level, set_record, add_filter,
       add_handler, remove_handler, remove_handlers, emit,
       get_logger, get_handlers, format,

       Logger,
       Record, DefaultRecord,
       Formatter, DefaultFormatter, JsonFormatter,
       Handler, DefaultHandler,
       FileRoller, Syslog


const DEFAULT_LOG_LEVEL = "warn"

const global _log_levels = Dict{AbstractString, Int}(
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

include("io.jl")
include("records.jl")
include("filters.jl")
include("formatters.jl")
include("handlers.jl")
include("loggers.jl")

# Initializing at compile-time will work as long as the loggers which are added do not
# contain references to STDOUT.
const global _loggers = Dict{AbstractString, Logger}(
    "root" => Logger("root"),
)

end
