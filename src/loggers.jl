typealias LoggingComponent Union{Formatter, Handler}

function get_mode(component::LoggingComponent)
    if in(:_mode, fieldnames(component))
        return component._mode
    else
        return nothing
    end
end

function set_mode!(component::LoggingComponent, mode)
    if get_mode(component) != nothing
        component._mode = mode
    end
end

type Logger
    handlers::Dict{Any, Handler}
    fmts::Vector{Formatter}
    modes::Array

    function Logger(; handlers::Dict{Any, Handler}=Dict{Any, Handler}(),
                    fmts=Vector{Formatter}(), modes = Any[])

        logger = new(handlers, fmts, modes)

        # defaults
        configure(logger)
        add_formatter(logger, msec_date_fmt)
        add_handler(
            logger,
            DefaultHandler(
                STDOUT, nothing, Dict{Symbol,Any}(:is_colorized => true)
            ),
            "console"
        )

        logger
    end
end

# -------

function configure(logger::Logger;
                   modes=["debug", "info", "warn", "error"],
                   handlers=Dict{Any, Dict}())

    logger.modes = modes

    for (handler, settings) in handlers
        configure(logger.handlers[handler]; settings...)
    end
end

configure(; args...) = configure(get_logger(); args...)

function format(logger::Logger, handler::Handler, args::Dict)

    for fmt in get_formatters(handler)
        if (get_mode(fmt) != nothing && get_mode(handler) != nothing
            && get_mode_index(logger, args[:mode]) < get_mode_index(logger, get_mode(handler)))
            continue
        end

        args = fmt(args)
    end

    return args
end

function log(logger::Logger, mode::AbstractString, msg::AbstractString, args::Dict)
    args[:mode] = mode
    args[:msg] = msg

    if mode in logger.modes
        for fmt in logger.fmts
            if (get_mode(fmt) != nothing &&
                get_mode_index(logger, mode) < get_mode_index(logger, get_mode(fmt)))
                continue
            end

            args = fmt(args)
        end

        # Iterate over the handlers
        for (name, handler) in logger.handlers
            if (get_mode(handler) != nothing
                && get_mode_index(logger, mode) < get_mode_index(logger, get_mode(handler)))
                continue
            end

            log(handler, format(logger, handler, args))
        end
    end
end

log(mode::AbstractString, msg::AbstractString, args::Dict) = log(get_logger(), mode, msg, args)

log(mode::AbstractString, args::Dict) = log(get_logger(), mode, "", args)



debug(logger::Logger, msg::AbstractString, args::Dict) = log(logger, "debug", msg, args)

debug(msg::AbstractString, args::Dict) = debug(get_logger(), msg, args)

debug(msg::AbstractString...) = debug(get_logger(), string(msg...))


info(logger::Logger, msg::AbstractString, args::Dict) = log(logger, "info", msg, args)

info(msg::AbstractString, args::Dict) = info(get_logger(), msg, args)

info(msg::AbstractString...; prefix = "info: ") = info(get_logger(), string(msg...))


warn(logger::Logger, msg::AbstractString, args::Dict) = log(logger, "warn", msg, args)

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

    log(logger, "error", msg, args)

    throw(ErrorException(exception_msg))
end

error(msg::AbstractString, args::Dict) = error(get_logger(), msg, args)

error(msg...) = error(get_logger(), string(msg...))

# -------

# Allow the args dict to be passed in by kwargs instead.

function log(logger::Logger, mode::AbstractString, msg::AbstractString; kwargs...)
    log(logger, mode, msg, Dict{Symbol, Any}(kwargs))
end

function log(mode::AbstractString, msg::AbstractString; kwargs...)
    log(get_logger(), mode, msg; kwargs...)
end

function log(mode::AbstractString; kwargs...)
    log(get_logger(), mode, ""; kwargs...)
end

for mode in (:debug, :info, :warn, :error)
    @eval begin
        function $mode(logger::Logger, msg::AbstractString; kwargs...)
            $mode(logger, msg, Dict{Symbol, Any}(kwargs))
        end

        $mode(msg::AbstractString; kwargs...) = $mode(get_logger(), msg; kwargs...)
    end
end

# -------

function add_formatter(logger::Logger, fmt_fn::Function, index::Integer=length(logger.fmts)+1)
    insert!(logger.fmts, index, Formatter(fmt_fn))
end

function add_formatter(fmt_fn::Function, index::Integer=length(get_logger().fmts)+1)
    add_formatter(get_logger(), fmt_fn, index)
end

# Like handlers, formatters that are only used only for certain logging modes can be added.

function add_formatter(logger::Logger, fmt::Formatter, index::Integer=length(logger.fmts)+1)
    insert!(logger.fmts, index, fmt)
end

function add_formatter(fmt::Formatter, index::Integer=length(get_logger().fmts)+1)
    add_formatter(get_logger(), fmt, index)
end


function remove_formatter(logger::Logger, index=length(logger.fmts))
    splice!(logger.fmts, index)
end

remove_formatter(index=length(get_logger().fmts)) = remove_formatter(get_logger(), index)

remove_formatters(logger::Logger=get_logger()) = empty!(logger.fmts)

function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    logger.handlers[name] = handler
end

function add_handler(handler::Handler, name=string(Base.Random.uuid4()))
    add_handler(get_logger(), handler, name)
end

remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

remove_handler(name) = remove_handler(get_logger(), name)

remove_handlers(logger::Logger=get_logger()) = empty!(logger.handlers)

# -------

function get_mode_index(logger::Logger, mode)
    index = findfirst(logger.modes, mode)
    index > 0 ? index : length(logger.modes) + 1
end
