

type LumberMill
    loggers::Dict
    format

    LumberMill() = new({ "console" => STDOUT }, CommonLog)
    LumberMill(mode::String, io::IO) = new(mode, io)
end

global lumber_mill = LumberMill()

# -------
# Add / Delete output loggers

add!(lm::LumberMill, logger::String, io::IO) = (lm.loggers[logger] = io)

delete!(lm::LumberMill, logger::String) = delete!(lm.loggers, logger)

# -------
# Interface for logging messages

function log(lm::LumberMill, level::String, msg::String, meta::Dict)
    formatted_log = (lm.format)(level, msg, meta)

    for (l,io) in lm.loggers
        println(io, formatted_log)
    end
end

function log(level::String, msg::String, meta::Dict)

end

function log(level::String, loggLogFormat)

end

info(msg::String, meta::Dict) = log("info", msg, meta)

warn(msg::String, meta::Dict) = log("warn", msg, meta)

error(msg::String, meta::Dict) = log("error", msg, meta)