VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Lumberjack

import Base.show, Base.info, Base.log, Compat.@compat
#import Mocking: @mendable # TODO - figure out how to use Mocking on 0.5

if !isdefined(Base, :StackTraces)
    import StackTraces
end

# To avoid warnings, intentionally do not import:
# Base.error, Base.warn, Base.info

export log, debug, info, warn, error,
       add_formatter, remove_formatter, remove_formatters,
       add_handler, remove_handler, remove_handlers,
       configure,

       Logger,
       Handler,
       DefaultHandler,
       SimpleHandler,
       JsonHandler,
       Formatter,
       FileRoller,
       Syslog

# -------

global _loggers

include("formatters.jl")
include("handlers.jl")
include("loggers.jl")
include("file_roller.jl")
include("syslog.jl")

# -------

function __init__()
    global _loggers = Dict{Any, Logger}(
        "root" => Logger()
    )
end

get_logger(name="root") = _loggers[name]

# -------

end
