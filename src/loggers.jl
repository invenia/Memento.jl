type Logger
    name::AbstractString
    handlers::Dict{Any, Handler}
    level::AbstractString
    levels::Dict{AbstractString, Int}
    record::Type
    propagate::Bool
end

function Logger{R<:Record}(name; level="not_set", levels=_log_levels,
                record::Type{R}=DefaultRecord, propagate=true)
    Logger(
        name,
        Dict{Any, Handler}(),
        level,
        levels,
        record,
        propagate
    )
end


Base.show(io::IO, logger::Logger) = print(io, "Logger($(logger.name))")

is_root(logger::Logger) = logger.name == "root" || logger.name == ""

is_set(logger::Logger) = logger.level != "not_set"

function basic_config(level::AbstractString; fmt::AbstractString=DEFAULT_FMT_STRING, levels=_log_levels, colorized=true)
    global _log_levels = levels
    _loggers["root"] = Logger("root"; level=level, levels=levels)
    add_handler(
        _loggers["root"],
        DefaultHandler(
            STDOUT,
            DefaultFormatter(fmt),
            Dict{Symbol, Any}(:is_colorized => colorized)
        ),
        "console"
    )

    return _loggers["root"]
end

function reset!()
    empty!(_loggers)
    Memento.__init__()
end

function get_parent(name)
    tokenized = split(name, '.')

    if length(tokenized) == 1
        return get_logger("root")
    elseif length(tokenized) == 2
        return get_logger(tokenized[1])
    else
        return get_logger(join(tokenized[1:end-1], '.'))
    end
end

get_logger(name::Module) = get_logger("$name")

function get_logger(name="root")
    logger_name = name == "" ? "root" : name

    if !(haskey(_loggers, logger_name))
        parent = get_parent(logger_name)
        _loggers[logger_name] = Logger(logger_name)
    end

    return _loggers[logger_name]
end

set_record{R<:Record}(logger::Logger, rec::Type{R}) = logger.rec = rec

remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

get_handlers(logger::Logger) = logger.handlers

function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    logger.handlers[name] = handler
end

add_level(logger::Logger, level::AbstractString, val::Int) = logger.levels[level] = val

function set_level(logger::Logger, level::AbstractString)
    logger.levels[level]    # Throw a key error if the levels isn't in levels
    logger.level = level
end

get_level(logger::Logger) = return logger.level

function log(logger::Logger, args::Dict{Symbol, Any})
    level = args[:level]
    llevel = logger.level
    levels = logger.levels

    if llevel != "not_set" && haskey(levels, level) && levels[level] >= levels[llevel]
        for (name, handler) in logger.handlers
            log(handler, logger.record(args))
        end
    end

    if !is_root(logger) && logger.propagate
        log(get_parent(logger.name), args)
    end
end

function log(logger::Logger, level::AbstractString, msg::AbstractString)
    dict = Dict{Symbol, Any}(
        :name => logger.name,
        :level => level,
        :levelnum => logger.levels[level],
        :msg => msg
    )

    log(logger::Logger, dict)
end

#=
For our DEFAULT_LOG_LEVELS we generate the appropriate `:level(logger, msg)`
methods.
=#
for key in keys(_log_levels)
    if key != "not_set"
        level = Symbol(key)

        if _log_levels[key] < _log_levels["error"]
            @eval begin
                function $level(logger::Logger, msg::AbstractString)
                    log(logger, $key, msg)
                end
            end
        else
            @eval begin
                function $level(logger::Logger, msg::AbstractString)
                    log(logger, $key, msg)
                    throw(ErrorException(msg))
                end

                function $level(logger::Logger, exc::ErrorException)
                    $level(logger, sprint(io->showerror(io,err)), args)
                end
            end
        end
    end
end

"""
We special case `warn` as it is the only method that can take an exception,
but won't throw it.
"""
function warn(logger::Logger, exc::Exception)
    log(logger, "warn", sprint(io -> showerror(io, exc)))
end
