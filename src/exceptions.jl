"""
    LoggerSerializationError(logger::Logger)

Provides a helpful error message when a logger cannot be serialized.
"""
struct LoggerSerializationError <: Exception
    logger::Logger
end

function Base.showerror(io::IO, e::LoggerSerializationError)
    print(io, string(
        "$(typeof(e)): $(e.logger) was unable to be serialized. ",
        "Perhaps try not using shared loggers between processes?",
    ))
end
