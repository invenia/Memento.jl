import Base: info, warn, error

type Logger
    name::AbstractString
    handlers::Dict{Any, Handler}
    level::AbstractString
    levels::Dict{AbstractString, Int}
    record::Function
end

function Logger(name; level=DEFAULT_LOG_LEVEL, levels=DEFAULT_LOG_LEVELS, record::Function=default_record)
    logger = Logger(
        name,
        Dict{Any, Handler}(),
        level,
        levels,
        record
    )

    add_handler(
        logger,
        DefaultHandler(
            STDOUT, DefaultFormatter(),
            Dict{Symbol,Any}(:is_colorized => true)
        ),
        "console"
    )

    logger
end

get_handlers(logger::Logger) = logger.handlers

function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    logger.handlers[name] = handler
end

remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

function set_level(logger::Logger, level::AbstractString)
    logger.levels[level]    # Throw a key error if the levels isn't in levels
    logger.level = level
end

add_level(logger::Logger, level::AbstractString, val::Int) = logger.levels[level] = val

set_record(logger::Logger, rec::Function) = logger.rec = rec

function log(logger::Logger, level::AbstractString, msg::AbstractString)
    dict = Dict{Symbol, Any}(
        :name => logger.name,
        :level => level,
        :levelnum => logger.levels[level],
        :msg => msg
    )

    if logger.levels[level] >= logger.levels[logger.level]
        for (name, handler) in logger.handlers
            log(handler, logger.record(dict))
        end
    end
end

#=
For our DEFAULT_LOG_LEVELS we generate the appropriate `:level(logger, msg)`
methods.
=#
for key in keys(DEFAULT_LOG_LEVELS)
    level = Symbol(key)

    if DEFAULT_LOG_LEVELS[key] < DEFAULT_LOG_LEVELS["error"]
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

"""
We special case `warn` as it is the only method that can take an exception,
but won't throw it.
"""
function warn(logger::Logger, exc::Exception)
    log(logger, "warn", sprint(io -> showerror(io, exc)), args)
end
