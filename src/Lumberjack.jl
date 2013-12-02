
module Lumberjack

import Base.show, Base.log

using Datetime
using UUID

export log,
       add_saw, remove_saw, remove_saws,
       add_truck, remove_truck, remove_trucks,
       configure


# -------

include("saws.jl")
include("timbertruck.jl")
include("lumbermill.jl")

# -------

end
