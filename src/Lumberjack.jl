
module Lumberjack

import Base.show, Base.log, Base.info, Base.warn, Base.error

using Datetime
using UUID

export log, info, warn, error

# -------

include("timbertruck.jl")
include("lumbermill.jl")

# -------

end
