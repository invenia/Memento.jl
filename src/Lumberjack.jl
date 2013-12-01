
module Lumberjack

import Base.show, Base.log, Base.info, Base.warn, Base.error

using Datetime
using UUID

export log, debug, info, warn, error,
       add_saw, remove_saw,
       add_truck, remove_truck,
       configure


# -------

include("saws.jl")
include("timbertruck.jl")
include("lumbermill.jl")

# -------

end
