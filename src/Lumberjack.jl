
module Lumberjack

import Base.show, Base.log, Base.info, Base.warn, Base.error, Base.add!

using Datetime

export log, info, warn, error, add!, delete!

# -------

include("logformat.jl")
include("lumbermill.jl")

# -------

end
