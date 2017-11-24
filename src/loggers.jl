"""
    Logger

A `Logger` is responsible for converting msg strings into
`Records` which are then passed to each handler. By default
loggers propagate their message to their parent loggers.

# Fields
* `name::AbstractString`: is the name of the logger (required).
* `handlers::Dict{Any, Handler}`: is a collection of `Handler`s (defaults to empty `Dict`).
* `level::AbstractString`: the current minimum logging level for the logger to
   log message to handlers (defaults to "not_set").
* `levels::Dict{AbstractString, Int}`: a mapping of available logging levels to their
    relative priority (represented as integer values) (defaults to using `Memento._log_levels`)
* `record::Type`: the `Record` type that should be produced by this logger
    (defaults to `DefaultRecord`).
* `propagate::Bool`: whether or not this logger should propagate its message to its parent
    (defaults to `true`).
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
        @assert haskey(levels, DEFAULT_LOG_LEVEL)

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

function Logger{R<:Record}(name; level=DEFAULT_LOG_LEVEL, levels=_log_levels,
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
        level = rec[:level]
        return haskey(l.levels, level) && l.levels[level] >= l.levels[l.level]
    end

    Memento.Filter(level_filter)
end

"""
    Base.show(::IO, ::Logger)

Just prints `Logger(logger.name)`
"""
Base.show(io::IO, logger::Logger) = print(io, "Logger($(logger.name))")

"""
    is_root(::Logger)

Returns true if `logger.name`is "root" or ""
"""
is_root(logger::Logger) = logger.name == "root" || logger.name == ""

"""
    is_set(::Logger)

Returns true or false as to whether the logger is set. (ie: logger.level != "not_set")
"""
is_set(logger::Logger) = logger.level != "not_set"

"""
    get_level(::Logger)

Returns the current logger level.
"""
get_level(logger::Logger) = logger.level

"""
    config(level::AbstractString; fmt::AbstractString, levels::Dict{AbstractString, Int}, colorized::Bool) -> Logger

Sets the `Memento._log_levels`, creates a default root logger with a `DefaultHandler`
that prints to STDOUT.

# Arguments
* `level::AbstractString`: the minimum logging level to log message to the root logger (required).
* `fmt::AbstractString`: a format string to pass to the `DefaultFormatter` which describes
    how to log messages (defaults to `Memento.DEFAULT_FMT_STRING`)
* `levels`: the default logging levels to use (defaults to `Memento._log_levels`).
* `colorized`: whether or not the message to STDOUT should be colorized.

# Returns
* `Logger`: the root logger.
"""
function config(level::AbstractString; fmt::AbstractString=DEFAULT_FMT_STRING, levels=_log_levels, colorized=true)
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
    reset!()

Removes all registered loggers and reinitializes the root logger
without any handlers.
"""
function reset!()
    empty!(_loggers)
    _loggers["root"] = Logger("root")
    nothing
end

"""
    get_parent(name::AbstractString) -> Logger

Takes a string representing the name of a logger and returns
its parent. If the logger name has no parent then the root logger is returned.
Parent loggers are extracted assuming a naming convention of "foo.bar.baz", where
"foo.bar.baz" is the child of "foo.bar" which is the child of "foo"

# Arguments
* `name::AbstractString`: the name of the logger.

# Returns
* `Logger`: the parent logger.
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
    get_logger(name::Module) -> Logger

Converts the `Module` to a `String` and calls `get_logger(name::String)`.

# Arguments
* `name::Module`: the Module a logger should be associated

# Returns
* `Logger`: the logger associated with the provided Module.

Returns the logger.
"""
get_logger(name::Module) = get_logger("$name")

"""
    get_logger(name::AbstractString) -> Logger

If the logger or its parents do not exist then they are initialized
with no handlers and not set.

# Arguments
* `name::AbstractString`: the name of the logger (defaults to "root")

# Returns
* `Logger`: the logger.
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
    set_record{R<:Record}(logger::Logger, rec::Type{R})

Sets the record type for the logger.

# Arguments
* `logger::Logger`: the logger to set.
* `rec::Record`: A `Record` type to use for logging messages (ie: `DefaultRecord`).
"""
set_record{R<:Record}(logger::Logger, rec::Type{R}) = logger.record = rec

"""
    remove_handler(logger::Logger, name)

Removes the `Handler` with the provided name from the logger.handlers.
"""
remove_handler(logger::Logger, name) = delete!(logger.handlers, name)

"""
    get_handlers(logger::Logger)

Returns logger.handlers
"""
get_handlers(logger::Logger) = logger.handlers

"""
    add_handler(logger::Logger, handler::Handler, name)

Adds a new handler to `logger.handlers`. If a name is not provided a
random one will be generated.

# Arguments
* `logger::Logger`: the logger to use.
* `handler::Handler`: the handler to add.
* `name::AbstractString`: a name to identify the handler.
"""
function add_handler(logger::Logger, handler::Handler, name=string(Base.Random.uuid4()))
    handler.levels.x = logger.levels
    logger.handlers[name] = handler
end

"""
    add_level(logger::Logger, level::AbstractString, val::Int)

Adds a new `level::String` and `priority::Int` to the `logger.levels`
"""
add_level(logger::Logger, level::AbstractString, val::Int) = logger.levels[level] = val

"""
    set_level(logger::Logger, level::AbstractString)

Changes what level this logger should log at.
"""
function set_level(logger::Logger, level::AbstractString)
    logger.levels[level]    # Throw a key error if the levels isn't in levels
    logger.level = level
end

"""
    log(logger::Logger, args::Dict{Symbol, Any})

Logs `logger.record(args)` to its handlers if it has the appropriate `args[:level]`
and `args[:level]` is above the priority of `logger.level`.
If this logger is not the root logger and `logger.propagate` is `true` then the
parent logger is called.

NOTE: This method calls all handlers asynchronously and is recursive, so you should call this
method with a `@sync` in order to synchronize all handler tasks.

# Arguments
* `logger::Logger`: the logger to log `args` to.
* `args::Dict`: a dict of msg fields and values that should be passed to `logger.record`.
"""
function log(logger::Logger, rec::Record)
    # If none of the `Filter`s return false we're good to log our record.
    if all(f -> f(rec), logger.filters)
        for (name, handler) in logger.handlers
            @async log(handler, rec)
        end
    end

    if !is_root(logger) && logger.propagate
        log(get_parent(logger.name), rec)
    end
end

"""
    log(logger::Logger, level::AbstractString, msg::AbstractString)

Creates a `Dict` with the logger name, level, levelnum and message and
calls the other `log` method (which may recursively call itself on parent loggers
with the created `Dict`).

# Arguments
* `logger::Logger`: the logger to log to.
* `level::AbstractString`: the log level as a `String`
* `msg::AbstractString`: the msg to log as a `String`

# Throws
* `CompositeException`: may be thrown if an error occurs in one of the handlers
   (which are run with `@async`)
"""
function log(logger::Logger, level::AbstractString, msg::AbstractString)
    rec = logger.record(logger.name, level, logger.levels[level], msg)
    @sync log(logger, rec)
end

"""
    log(::Function, ::Logger, ::AbstractString)

Same as `log(logger, level, msg)`, but in this case the message can
be a function that returns the log message string.

# Arguments
* `msg::Function`: a function that returns a message `String`
* `logger::Logger`: the logger to log to.
* `level::AbstractString`: the log level as a `String`

# Throws
* `CompositeException`: may be thrown if an error occurs in one of the handlers
   (which are run with `@async`)
"""
function log(msg::Function, logger::Logger, level::AbstractString)
    rec = logger.record(logger.name, level, logger.levels[level], msg)
    @sync log(logger, rec)
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
                    log(logger, $key, sprint(io -> showerror(io, exc)))
                    throw(exc)
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
    $level(logger::Logger, msg::AbstractString)

Logs the message at the $level level.

    $level(msg::Function, logger::Logger)

Logs the message produced by the provided function at the $level level.
"""
@doc msg("debug") debug
@doc msg("info") info
@doc msg("notice") notice
@doc msg("warn") warn

msg = (level) -> """
    $level(logger::Logger, msg::AbstractString)

Logs the message at the $level level and throws an `ErrorException` with that message

    $level(msg::Function, logger::Logger)

Logs the message produced by the provided function at the $level level and throws an `ErrorException` with that message.

    $level(logger::Logger, exc::Exception)

Calls `$level(logger, msg)` with the contents of the `Exception`.
"""

@doc msg("error") error
@doc msg("critical") critical
@doc msg("alert") alert
@doc msg("emergency") emergency

"""
    warn(logger::Logger, exc::Exception)

Takes an exception and logs it.
"""
function warn(logger::Logger, exc::Exception)
    log(logger, "warn", sprint(io -> showerror(io, exc)))
end
