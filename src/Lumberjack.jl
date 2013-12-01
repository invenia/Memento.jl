
module Lumberjack

import Base.show, Base.log

using Datetime
using UUID

export log,
       add_saw, remove_saw,
       add_truck, remove_truck,
       configure


# -------

include("saws.jl")
include("timbertruck.jl")
include("lumbermill.jl")

# -------

end
