function Syslog(facility=:local0, tag="julia", tag_pid::Bool=false)
    Base.depwarn("Syslog has been moved to Syslogs.jl", :Syslog)
    Syslogs.Syslog(facility)
end

"""
    emit{F, O}(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}

Handles printing any records with any `Formatter` and a `Syslog` `IO` type.
"""
function Memento.emit(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslogs.Syslog}
    Base.depwarn("The custom `Memento.emit` method for Syslog IO types will not be provided in the future.", :emit)
    println(handler.io, rec[:level], format(handler.fmt, rec))
    flush(handler.io)
end

@deprecate JsonFormatter(aliases=Nullable()) DictFormatter(aliases, JSON.json)