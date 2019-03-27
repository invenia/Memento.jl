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
mutable struct Logger
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

        push!(logger, Memento.Filter(rec -> isset(logger)))
        push!(logger, Memento.Filter(logger))

        return logger
    end
end

function Logger(name; level=DEFAULT_LOG_LEVEL, levels=_log_levels,
                record::Type{R}=DefaultRecord, propagate=true) where {R<:Record}
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
        level = getlevel(rec)
        levels = getlevels(l)
        return haskey(levels, level) && levels[level] >= levels[getlevel(l)]
    end

    Memento.Filter(level_filter)
end

"""
    Base.show(::IO, ::Logger)

Just prints `Logger(logger.name)`
"""
Base.show(io::IO, logger::Logger) = print(io, "Logger($(logger.name))")

"""
    isroot(::Logger)

Returns true if `logger.name`is "root" or ""
"""
isroot(logger::Logger) = logger.name == "root" || logger.name == ""

"""
    isset(::Logger)

Returns true or false as to whether the logger is set. (ie: logger.level != "not_set")
"""
isset(logger::Logger) = getlevel(logger) != "not_set"

"""
    ispropagating(::Logger)

Returns true or false as to whether the logger is propagating.
"""
ispropagating(logger::Logger) = logger.propagate

"""
    setpropagating!([::Function], ::Logger, [::Bool])

Sets the logger to be propagating or not (Defaults to true).
"""
setpropagating!(logger::Logger, val::Bool=true) = logger.propagate = val

function setpropagating!(f::Function, logger::Logger, val::Bool=true)
    init_val = logger.propagate
    logger.propagate = val

    try
        f()
    finally
        logger.propagate = init_val
    end
end

"""
    getlevel(::Logger) -> AbstractString

Returns the current logger level.
"""
getlevel(logger::Logger) = logger.level

"""
    getlevels(::Logger) -> Dict

Get the available log levels for a logger and their associated priorities.
"""
getlevels(logger::Logger) = logger.levels

"""
    register(::Logger)

Register an existing logger with Memento if it has not already been registered.
"""
function register(logger::Logger)
    if !haskey(_loggers, logger.name)
        _loggers[logger.name] = logger
    else
        debug(LOGGER, "$logger is already registered.")
    end
end

"""
    getpath(logger::Logger) -> Vector{Logger}

Returns the path of logger from the root logger.
"""
function getpath(logger::Logger)
    isroot(logger) && return [logger]

    tokenized = split(logger.name, '.')
    results = Vector{Logger}(undef, length(tokenized) + 1)

    # Set the root logger as the first element
    results[1] = getlogger("root")
    # Set our input logger as the last logger in case the
    # input logger isn't registered.
    results[end] = logger

    for i in 1:length(tokenized)-1
        results[i+1] = getlogger(join(tokenized[1:i], '.'))
    end

    return results
end

function Serialization.serialize(s::AbstractSerializer, logger::Logger)
    try
        invoke(serialize, Tuple{AbstractSerializer, Any}, s, logger)
    catch e
        if e isa ErrorException && e.msg == "cannot serialize a running Task"
            rethrow(LoggerSerializationError(logger))
        else
            rethrow()
        end
    end
end

"""
    getchildren(name)

Takes a string representing the name of a logger and returns its children.
Child loggers are extracted assuming a naming convention of "foo.bar.baz", where
"foo.bar.baz" is the child of "foo.bar" which is the child of "foo".

# Arguments
* `name`: the name of the logger.

# Returns
* `Vector{Logger}`
"""
function getchildren(name)
    names = Iterators.filter(keys(_loggers)) do n
        name == "root" ? n != name : startswith(n, "$name.")
    end

    return map(n -> _loggers[n], names) # TODO: using `imap`
end

"""
    getlogger(name::Module) -> Logger

Converts the `Module` to a `String` and calls `get_logger(name::String)`.

# Arguments
* `name::Module`: the Module a logger should be associated

# Returns
* `Logger`: the logger associated with the provided Module.

Returns the logger.
"""
getlogger(name::Module) = getlogger("$name")

"""
    getlogger(name="root") -> Logger

If the logger or its parents do not exist then they are initialized
with no handlers and not set.

# Arguments
* `name`: the name of the logger (defaults to "root")

# Returns
* `Logger`: the logger.
"""
function getlogger(name="root")
    logger_name = name == "" ? "root" : name

    if !(haskey(_loggers, logger_name))
        register(Logger(logger_name))
    end

    return _loggers[logger_name]
end

"""
    setrecord!(logger::Logger, rec::Type{R}) where {R<:Record}

Sets the record type for the logger.

# Arguments
* `logger::Logger`: the logger to set.
* `rec::Record`: A `Record` type to use for logging messages (ie: `DefaultRecord`).
"""
setrecord!(logger::Logger, rec::Type{R}) where {R<:Record} = logger.record = rec

"""
    getfilters(logger::Logger) -> Array{Filter}

Returns the filters for the logger.
"""
getfilters(logger::Logger) = logger.filters

"""
    push!(logger::Logger, filter::Memento.Filter)

Adds an new `Filter` to the logger.
"""
Base.push!(logger::Logger, filter::Memento.Filter) = push!(logger.filters, filter)

"""
    gethandlers(logger::Logger)

Returns logger.handlers
"""
gethandlers(logger::Logger) = logger.handlers

"""
    push!(logger::Logger, handler::Handler)

Adds a new `Handler` to the logger.
"""
function Base.push!(logger::Logger, handler::Handler)
    logger.handlers[string(uuid4())] = handler
end

"""
    addlevel!(logger::Logger, level::AbstractString, val::Int)

Adds a new `level::String` and `priority::Int` to the `logger.levels`
"""
addlevel!(logger::Logger, level::AbstractString, val::Int) = logger.levels[level] = val

"""
    setlevel!(logger::Logger, level::AbstractString; recursive=false)

Changes what level this logger should log at.
"""
function setlevel!(logger::Logger, level::AbstractString; recursive=false)
    getlevels(logger)[level]    # Throw a key error if the levels isn't in levels
    logger.level = level

    # Unfortunately, recursive flag isn't implemented recursively
    if recursive
        for l in getchildren(logger.name)
            setlevel!(l, level)
        end
    end
end

"""
    setlevel!(f::Function, logger::Logger, level::AbstractString; recursive=false)

Temporarily change the level a logger will log at for the duration of the function `f`.
"""
function setlevel!(f::Function, logger::Logger, level::AbstractString; recursive=false)
    # The recursive condition is less performant, so we'll special case it.
    if recursive
        loggers = getchildren(logger.name)
        push!(loggers, logger)

        originals = getlevel.(loggers)

        try
            setlevel!.(loggers, level)
            f()
        finally
            for (lo, le) in zip(loggers, originals)
                setlevel!(lo, le)
            end
        end
    else
        original = getlevel(logger)
        setlevel!(logger, level)

        try
            f()
        finally
            setlevel!(logger, original)
        end
    end
end

"""
    log(logger::Logger, rec::Record)

Logs `rec` to all its logger handlers. If this logger is not the root logger and
`logger.propagate` is `true` then the parent logger is called.

NOTE: This method calls all handlers asynchronously and is recursive, so you should call
it with a `@sync` in order to synchronize all handler tasks.

# Arguments
* `logger::Logger`: the logger to log `args` to.
* `rec::Record`: a `Record` to log
"""
function log(logger::Logger, rec::Record)
    for l in reverse!(getpath(logger))
        # If none of the `Filter`s return false we're good to log our record.
        !all(f -> f(rec), getfilters(l)) && break

        # Log to all of our handlers
        for (name, handler) in l.handlers
            log(handler, rec)
        end

        # Break if this is the root logger or it's non-propagating
        isroot(l) || !l.propagate && break
    end
end

"""
    log(logger::Logger, level::AbstractString, msg::AbstractString)

Creates a `Record` with the logger name, level, levelnum and message and
calls the other `log` method (which may recursively call itself on parent loggers
with the created `Record`).

# Arguments
* `logger::Logger`: the logger to log to.
* `level::AbstractString`: the log level as a `String`
* `msg::AbstractString`: the msg to log as a `String`

# Throws
* `CompositeException`: may be thrown if an error occurs in one of the handlers
   (which are run with `@async`)
"""
log(logger::Logger, level::AbstractString, msg::AbstractString) = _log(logger, level, msg)

"""
    log(::Function, ::Logger, ::AbstractString)

Same as `log(logger, level, msg)`, but in this case the message can
be a function that returns the log message string.

# Arguments
* `msg::Function`: a function that returns a message `String`
* `logger::Logger`: the logger to log to
* `level::AbstractString`: the log level as a `String`

# Throws
* `CompositeException`: may be thrown if an error occurs in one of the handlers
   (which are run with `@async`)
"""
log(msg::Function, logger::Logger, level::AbstractString) = _log(logger, level, msg)

function _log(logger::Logger, level::AbstractString, msg)
    rec = logger.record(logger.name, level, getlevels(logger)[level], msg)
    log(logger, rec)
end

#=
For our DEFAULT_LOG_LEVELS we generate the appropriate `:level(logger, msg)`
methods.
=#
let
    for key in keys(_log_levels)
        if key != "not_set"
            local level = Symbol(key)

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

                    function $level(logger::Logger, exc::CompositeException)
                        for sub_exc in exc
                            log(logger, $key, sprint(io -> showerror(io, sub_exc)))
                        end
                        throw(exc)
                    end
                end
                f = eval(level)
            end
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

Calls `$level(logger, msg)` with the contents of the `Exception`, then throw the `Exception`.
If the exception is a `CompositeException`, each contained exception is logged, then the `CompositeException` is thrown.
"""

@doc msg("error") error
@doc msg("critical") critical
@doc msg("alert") alert
@doc msg("emergency") emergency

"""
    warn(logger::Logger, exc::Exception)

Takes an exception and logs it.
If the exception is a `CompositeException`, each contained exception is logged.
"""
function warn(logger::Logger, exc::Exception)
    log(logger, "warn", sprint(io -> showerror(io, exc)))
end

function warn(logger::Logger, exc::CompositeException)
    for sub_exc in exc
        log(logger, "warn", sprint(io -> showerror(io, sub_exc)))
    end
end
