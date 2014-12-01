module Lumberjack

import Base.show, Base.log

# To avoid warnings, intentionally do not import:
# Base.error, Base.warn, Base.info
using UUID

export log,
       debug, info, warn, error,
       add_saw, remove_saw, remove_saws,
       add_truck, remove_truck, remove_trucks,
       configure,

       TimberTruck,
       LumberjackTruck,
       CommonLogTruck


# -------

include("saws.jl")
include("timbertruck.jl")
include("lumbermill.jl")

# -------

end
