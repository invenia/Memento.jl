__precompile__()

module Memento

using Compat
using Compat.Dates

import Syslogs
import JSON

import Base: show, info, warn, error, log

export debug, notice, error, critical, alert, emergency,
       isset, isroot, ispropagating, setpropagating!,
       getlevel, setlevel!, addlevel!, setrecord!,
       getlogger, gethandlers, getfilters, format, emit,

       Logger,Record, DefaultRecord, Formatter, Handler,
       DefaultFormatter, DictFormatter, DefaultHandler, FileRoller,

       # Deprecated
       Syslog,
       JsonFormatter,
       is_set,
       is_root,
       get_level,
       set_level,
       add_level,
       set_record,
       filters,
       add_filter,
       add_handler,
       remove_handler,
       get_logger,
       get_handlers

const DEFAULT_LOG_LEVEL = "warn"

const _log_levels = Dict{AbstractString, Int}(
    "not_set" => 0,
    "debug" => 10,
    "info" => 20,
    "notice" => 30,
    "warn" => 40,
    "error" => 50,
    "critical" => 60,
    "alert" => 70,
    "emergency" => 80
)

include("io.jl")
include("records.jl")
include("filters.jl")
include("formatters.jl")
include("handlers.jl")
include("loggers.jl")
include("deprecated.jl")

# Initializing at compile-time will work as long as the loggers which are added do not
# contain references to STDOUT.
const _loggers = Dict{AbstractString, Logger}(
    "root" => Logger("root"),
)

function __init__()
    Memento.config("warn")
end

end
