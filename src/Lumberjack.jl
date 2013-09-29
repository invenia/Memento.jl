
module Lumberjack

# -------

type LumberMill
    mode    # debug, release
    io::IO

    LumberMill() = new("debug", Base.STDOUT)
    LumberMill(mode::String, io::IO) = new(mode, io)
end

global lumber_mill = LumberMill()

# -------

function output_to(io::IO)
    lumber_mill.io = io
end

end
