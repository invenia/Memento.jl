VERSION >= v"0.4.0-dev+6521" && __precompile__()

module Lumberjack

import Base.show, Base.info, Base.log, Compat.@compat
#import Mocking: @mendable # TODO - figure out how to use Mocking on 0.5

if !isdefined(Base, :StackTraces)
    import StackTraces
end

# To avoid warnings, intentionally do not import:
# Base.error, Base.warn, Base.info

export log,
       debug, info, warn, error,
       add_saw, remove_saw, remove_saws,
       add_truck, remove_truck, remove_trucks,
       configure,

       TimberTruck,
       LumberjackTruck,
       CommonLogTruck,
       JsonTruck,
       Saw,
       FileRoller,
       Syslog

# -------

global _lumber_mill

include("saws.jl")
include("timbertruck.jl")
include("lumbermill.jl")
include("FileRoller.jl")
include("Syslog.jl")

# -------

function __init__()
    global _lumber_mill = LumberMill()
end

# -------

end
