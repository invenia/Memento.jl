# This is necessary or Memento will attempt to use `println` with one argument (unsupported by Syslog)
# This should be handled by optional dependency stuff in the future
"""
    emit(
        handler::DefaultHandler{F, O},
        rec::Record
    ) where {F<:Formatter, O<:Syslogs.Syslog}

Handles printing any records with any `Formatter` and a `Syslog` `IO` type.
"""
function Memento.emit(
    handler::DefaultHandler{F, O}, rec::Record
) where {F<:Formatter, O<:Syslogs.Syslog}

    println(handler.io, getlevel(rec), format(handler.fmt, rec))
    flush(handler.io)
end
