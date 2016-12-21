type Logger
    name::AbstractString
    handlers::Dict{Any, Handler}
    level::Symbol
    levels::Dict{Symbol, Int}
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

get_logger(name="root") = _loggers[name]

function configure(logger; kwargs...)
    dict = Dict(kwargs)

    if haskey(dict, :levels)
        logger.levels = dict[:levels]
    end

    if haskey(dict, :level)
        logger.level = dict[:level]
    end

    if haskey(dict, :record) && isa(args[:record], Type)
        logger.record = args[:record]
    end
end

configure(; kwargs...) = configure(get_logger(); kwargs...)

get_handlers(logger::Logger) = logger.handlers
get_handlers() = get_handlers(get_logger())

function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    logger.handlers[name] = handler
end

function add_handler(handler::Handler, name=string(Base.Random.uuid4()))
    add_handler(get_logger(), handler, name)
end

remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

remove_handler(name) = remove_handler(get_logger(), name)

remove_handlers(logger::Logger=get_logger()) = empty!(logger.handlers)

function set_level(logger::Logger, level::Symbol)
    logger.levels[level]    # Throw a key error if the levels isn't in levels
    logger.level = level
end

set_level(level::Symbol) = set_level(get_logger(), level)

add_level(logger::Logger, level::Symbol, val::Int) = logger.levels[level] = val

add_level(level::Symbol, val::Int) = add_level(get_logger(), level, val)

set_record(logger::Logger, rec::Function) = logger.rec = rec

set_record(rec::Function) = set_record(set_logger(), rec)

function log(logger::Logger, level::Symbol, msg::AbstractString, args::Dict)
    args[:name] = logger.name
    args[:level] = level
    args[:levelnum] = logger.levels[level]
    args[:msg] = msg

    if logger.levels[level] >= logger.levels[logger.level]
        for (name, handler) in logger.handlers
            log(handler, logger.record(args))
        end
    end
end

log(level::Symbol, msg::AbstractString, args::Dict) = log(get_logger(), level, msg, args)

log(level::Symbol, args::Dict) = log(get_logger(), level, "", args)


debug(logger::Logger, msg::AbstractString, args::Dict) = log(logger, :debug, msg, args)

debug(msg::AbstractString, args::Dict) = debug(get_logger(), msg, args)

debug(msg::AbstractString...) = debug(get_logger(), string(msg...))


info(logger::Logger, msg::AbstractString, args::Dict) = log(logger, :info, msg, args)

info(msg::AbstractString, args::Dict) = info(get_logger(), msg, args)

info(msg::AbstractString...; prefix = "info: ") = info(get_logger(), string(msg...))


warn(logger::Logger, msg::AbstractString, args::Dict) = log(logger, :warn, msg, args)

warn(msg::AbstractString, args::Dict) = warn(get_logger(), msg, args)

function warn(msg::AbstractString...; prefix="warning: ", once = false, key = nothing, bt = nothing)
    str = chomp(bytestring(msg...))

    if once
        if key === nothing
            key = str
        end

        (key in Base.have_warned) && return
        push!(Base.have_warned, key)
    end

    warn(
        get_logger(), str,
        bt !== nothing ? Dict{Symbol,Any}(:backtrace => sprint(show_backtrace, bt)) : Dict()
    )
end

warn(err::Exception; prefix = "error: ", kw...) =
    warn(sprint(io->showerror(io,err)), prefix = prefix; kw...)


function error(logger::Logger, msg::AbstractString, args::Dict)
    exception_msg = @compat identity(msg)
    length(args) > 0 && (exception_msg *= " $args")

    log(logger, :error, msg, args)

    throw(ErrorException(exception_msg))
end

error(msg::AbstractString, args::Dict) = error(get_logger(), msg, args)

error(msg...) = error(get_logger(), string(msg...))

# -------

# Allow the args dict to be passed in by kwargs instead.

function log(logger::Logger, level::Symbol, msg::AbstractString; kwargs...)
    log(logger, level, msg, Dict{Symbol, Any}(kwargs))
end

function log(level::Symbol, msg::AbstractString; kwargs...)
    log(get_logger(), level, msg; kwargs...)
end

function log(level::Symbol; kwargs...)
    log(get_logger(), level, ""; kwargs...)
end

for level in (:debug, :info, :warn, :error)
    @eval begin
        function $level(logger::Logger, msg::AbstractString; kwargs...)
            $level(logger, msg, Dict{Symbol, Any}(kwargs))
        end

        $level(msg::AbstractString; kwargs...) = $level(get_logger(), msg; kwargs...)
    end
end
