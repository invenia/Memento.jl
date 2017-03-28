"""
A `Logger` is responsible for converting msg strings into
`Records` which are then passed to each handler. By default
loggers propagate their message to their parent loggers.

Fields:

- `name`: is the name of the logger (required).
- `handlers`: is a collection of `Handler`s (defaults to empty `Dict`).
- `level`: the current minimum logging level for the logger to log message to handlers (defaults to "not_set").
- `levels`: a mapping of available logging levels to their relative priority (represented as integer values) (defaults to using `Memento._log_levels`)
- `record`: the `Record` type that should be produced by this logger (defaults to `DefaultRecord`).
- `propagate`: whether or not this logger should propagate its message to its parent (defaults to `true`).
"""

type Logger
    name::AbstractString
    handlers::Dict{Any, Handler}
    level::AbstractString
    levels::Dict{AbstractString, Int}
    filters::Array{Memento.Filter}
    record::Type
    propagate::Bool

    function Logger(name::AbstractString, handlers::Dict, level::AbstractString,
                    levels::Dict, record::Type, propagate::Bool)
        @assert haskey(levels, "not_set")

        logger = new(
            name,
            handlers,
            level,
            levels,
            Memento.Filter[],
            record,
            propagate
        )

        for (name, handler) in logger.handlers
            handler.levels = Ref(logger.levels)
        end

        push!(logger.filters, Memento.Filter(rec -> is_set(logger)))
        push!(logger.filters, Memento.Filter(logger))

        return logger
    end
end

function Logger{R<:Record}(name; level="not_set", levels=_log_levels,
                record::Type{R}=DefaultRecord, propagate=true)
    logger = Logger(
        name,
        Dict{Any, Handler}(),
        level,
        levels,
        record,
        propagate
    )
end

function Memento.Filter(l::Logger)
    function level_filter(rec::Record)
        level = get(rec, :level)

        if haskey(l.levels, level)
            return l.levels[level] >= l.levels[l.level]
        else
            warn("$level not in $(l.levels)")
            return false
        end
    end

    Memento.Filter(level_filter)
end

" `Base.show(::IO, ::Logger)` just prints `Logger(logger.name)` "
Base.show(io::IO, logger::Logger) = print(io, "Logger($(logger.name))")

" `is_root(::Logger)` returns true if `logger.name`is \"root\" or \"\" "
is_root(logger::Logger) = logger.name == "root" || logger.name == ""

" `is_set(:Logger)` returns true or false as to whether the logger is set. (ie: logger.level != \"not_set\") "
is_set(logger::Logger) = logger.level != "not_set"

"""
`basic_config(::AbstractString; ::AbstractString, ::Dict{AbstractString, Int}, colorized::Bool)`
sets the `Memento._log_levels`, creates a default root logger with a `DefaultHandler`
that prints to STDOUT.

Args:

- `level`: the minimum logging level to log message to the root logger (required).
- `fmt`: a format string to pass to the `DefaultFormatter` which describes how to log messages (defaults to `Memento.DEFAULT_FMT_STRING`)
- `levels`: the default logging levels to use (defaults to `Memento._log_levels`).
- `colorized`: whether or not the message to STDOUT should be colorized.

Returns the root logger.
"""
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

"""
`reset!` removes all registered loggers and reinitializes the root logger
without any handlers.
"""
function reset!()
    empty!(_loggers)
    Memento.__init__()
end

"""
`get_parent(::AbstractString)` takes a string representing the name of a logger and returns
its parent. If the logger name has no parent then the root logger is returned.
Parent loggers are extracted assuming a naming convention of "foo.bar.baz", where
"foo.bar.baz" is the child of "foo.bar" which is the child of "foo"

Args:

- name: the name of the logger.

Returns the parent logger.
"""
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

"""
`get_logger(name::Module)` converts the `Module` to a `String` and
calls `get_logger(name::String)`.

Args: name of the logger

Returns the logger.
"""
get_logger(name::Module) = get_logger("$name")

"""
`get_logger(::AbstractString)` returns the appropriate logger.
If the logger or its parents do not exist then they are initialized
with no handlers and not set.

Args: the name of the logger (defaults to "root")

Returns the logger.
"""
function get_logger(name="root")
    logger_name = name == "" ? "root" : name

    if !(haskey(_loggers, logger_name))
        parent = get_parent(logger_name)
        _loggers[logger_name] = Logger(logger_name)
    end

    return _loggers[logger_name]
end

"""
`set_record{R<:Record}(::Logger, ::Type{R})`
sets the record type for the logger.

Args:

- logger: the logger to set.
- rec: A `Record` type to use for logging messages (ie: `DefaultRecord`).
"""
set_record{R<:Record}(logger::Logger, rec::Type{R}) = logger.record = rec

" `remove_handler(::Logger, name)` removes the `Handler` with the
provided name from the logger.handlers. "
remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

" `get_handlers(::Logger)` returns logger.handlers"
get_handlers(logger::Logger) = logger.handlers

"""
`add_handler(::Logger, ::Handler, name)` adds a new handler to `logger.handlers`.
If a name is not provided a random one will be generated.

Args:

- logger: the logger to use.
- handler: the handler to add.
- name: a name to identify the handler.
"""
function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    handler.levels.x = logger.levels
    logger.handlers[name] = handler
end

""" `add_level(::Logger, ::AbstractString, ::Int)` adds a
new `level::String` and `priority::Int` to the `logger.levels`
"""
add_level(logger::Logger, level::AbstractString, val::Int) = logger.levels[level] = val

"""
`set_level(::Logger, ::AbstractString)` changes what level this logger should log at.
"""
function set_level(logger::Logger, level::AbstractString)
    logger.levels[level]    # Throw a key error if the levels isn't in levels
    logger.level = level
end

"""
`log(::Logger, ::Dict{Symbol, Any})` logs
`logger.record(args)` to its handlers if it has the appropriate `args[:level]`
and `args[:level]` is above the priority of `logger.level`.
If this logger is not the root logger and `logger.propagate` is `true` then the
parent logger is called.

Args:
- logger: the logger to log `args` to.
- args: a dict of msg fields and values that should be passed to `logger.record`.
"""
function log(logger::Logger, args::Dict{Symbol, Any})
    level = args[:level]
    llevel = logger.level
    levels = logger.levels

    rec = logger.record(args)

    # If none of the `Filter`s return false we're good to log our record.
    if all(f -> f(rec), logger.filters)
        for (name, handler) in logger.handlers
            log(handler, logger.record(args))
        end
    end

    if !is_root(logger) && logger.propagate
        log(get_parent(logger.name), args)
    end
end

"""
`log(::Logger, ::AbstractString, ::AbstractString)`
creates a `Dict` with the logger name, level, levelnum and message and
calls the other `log` method (which may recursively call itself on parent loggers
with the created `Dict`).

Args:
- logger: the logger to log to.
- level: the log level as a `String`
- msg: the msg to log as a `String`
"""
function log(logger::Logger, level::AbstractString, msg::AbstractString)
    dict = Dict{Symbol, Any}(
        :name => logger.name,
        :level => level,
        :levelnum => logger.levels[level],
        :msg => msg
    )

    log(logger, dict)
end

function log(msg::Function, logger::Logger, level::AbstractString)
    dict = Dict{Symbol, Any}(
        :name => logger.name,
        :level => level,
        :levelnum => logger.levels[level],
        :msg => msg
    )

    log(logger, dict)
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

                function $level(msg::Function, logger::Logger)
                    log(msg, logger, $key)
                end
            end
        else
            @eval begin
                function $level(logger::Logger, msg::AbstractString)
                    log(logger, $key, msg)
                    throw(ErrorException(msg))
                end

                function $level(msg::Function, logger::Logger)
                    log(msg, logger, $key)
                    throw(ErrorException(msg()))
                end

                function $level(logger::Logger, exc::Exception)
                    $level(logger, sprint(io->showerror(io,exc)))
                end
            end
            f = eval(level)
        end
    end
end

#=
Add our doc strings.
=#
msg = (level) -> """
`$level(::Logger, ::AbstractString)` logs the message at the $level level.
`$level(::Function, ::Logger)` logs the message produced by the provided function at the $level level.
"""
@doc msg("debug") debug
@doc msg("info") info
@doc msg("notice") notice
@doc msg("warn") warn

msg = (level) -> """
`$level(::Logger, ::AbstractString)` logs the message at the $level level and throws an `ErrorException` with that message
`$level(::Function, ::Logger)` logs the message produced by the provided function at the $level level and throws an `ErrorException` with that message.
`$level(::Logger, ::Exception)` calls `$level(logger, msg)` with the contents of the `Exception`.
"""

@doc msg("error") error
@doc msg("critical") critical
@doc msg("alert") alert
@doc msg("emergency") emergency

" `warn(::Logger, ::Exception)` takes an exception and logs it. "
function warn(logger::Logger, exc::Exception)
    log(logger, "warn", sprint(io -> showerror(io, exc)))
end
