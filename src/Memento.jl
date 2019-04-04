module Memento

using Base: StackTrace, StackFrame
using UUIDs
using Dates
using Sockets
using Distributed
using Serialization

import Syslogs
import JSON
using TimeZones

import Base: show, error, log, getindex

export info, warn, debug, notice, error, critical, alert, emergency,
       isset, isroot, ispropagating, setpropagating!,
       getlevel, setlevel!, addlevel!, setrecord!,
       getlogger, gethandlers, getfilters, format, emit,

       Logger, Record, AttributeRecord, DefaultRecord, Formatter, Handler,
       DefaultFormatter, DictFormatter, DefaultHandler, FileRoller,
       LoggerSerializationError


const DEFAULT_LOG_LEVEL = "info"

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
include("syslog.jl")
include("stdlib.jl")
include("config.jl")
include("exceptions.jl")
include("memento_test.jl")
include("deprecated.jl")

# Initializing at compile-time will work as long as the loggers which are added do not
# contain references to STDOUT.
const _loggers = Dict{AbstractString, Logger}(
    "root" => Logger("root"),
)

const LOGGER = getlogger(@__MODULE__)

function __init__()
    Memento.config!(DEFAULT_LOG_LEVEL)
    Memento.register(LOGGER)
end

end
