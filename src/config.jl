
"""
    config!([logger], level; fmt::AbstractString, levels::Dict{AbstractString, Int}, colorized::Bool) -> Logger

Sets the `Memento._log_levels`, creates a default root logger with a `DefaultHandler`
that prints to stdout.

# Arguments
* 'logger::Union{Logger, AbstractString}`: The logger to configure (optional)
* `level::AbstractString`: the minimum logging level to log message to the root logger (required).

# Keywords
* `fmt::AbstractString`: a format string to pass to the `DefaultFormatter` which describes
    how to log messages (defaults to `Memento.DEFAULT_FMT_STRING`)
* `levels`: the default logging levels to use (defaults to `Memento._log_levels`).
* `colorized`: whether or not the message to stdout should be colorized.
* `recursive`: whether or not to recursive set the level of all child loggers.
* `substitute`: whether or not to substitute the global logger with Memento
  (only supported on julia 0.7).
* `propagate`: whether the logger should also send messages to parent loggers (default: true)

# Returns
* `Logger`: the logger passed in, or the root logger.
"""
config!(level::AbstractString; kwargs...) = config!("root", level; kwargs...)

function config!(logger::AbstractString, level::AbstractString; kwargs...)
    config!(getlogger(logger), level; kwargs...)
end

function config!(
    logger::Logger, level::AbstractString;
    fmt::AbstractString=DEFAULT_FMT_STRING, levels=_log_levels, colorized=true,
    recursive=false, substitute=false, propagate=true
)
    logger.levels = levels
    setlevel!(logger, level; recursive=recursive)
    setpropagating!(logger, propagate)
    handler = DefaultHandler(
        stdout,
        DefaultFormatter(fmt), Dict{Symbol, Any}(:is_colorized => colorized)
    )
    logger.handlers["console"] = handler
    register(logger)

    substitute && substitute!()

    return logger
end

"""
    reset!()

Removes all registered loggers and reinitializes the root logger
without any handlers.
"""
function reset!()
    empty!(_loggers)
    register(Logger("root"))
    nothing
end
