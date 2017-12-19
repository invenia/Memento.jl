# BEGIN Memento 0.4 deprecations

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

# END Memento 0.4 deprecations

# BEGIN Memento 0.5 deprecations

# Logger deprecations
@deprecate is_root(logger::Logger) isroot(logger::Logger)
@deprecate is_set(logger::Logger) isset(logger::Logger)
@deprecate get_level(logger::Logger) getlevel(logger::Logger)
@deprecate get_parent(name) getparent(name)
@deprecate get_logger() getlogger()
@deprecate get_logger(name) getlogger(name)
@deprecate set_record(logger::Logger, rec) setrecord!(logger, rec)
@deprecate filters(logger::Logger) getfilters(logger::Logger)
@deprecate add_filter(logger::Logger, filter::Memento.Filter) push!(logger, filter)
@deprecate get_handlers(logger::Logger) gethandlers(logger::Logger)
@deprecate add_level(logger::Logger, level, val) addlevel!(logger, level, val)
@deprecate set_level(logger::Logger, level) setlevel!(logger, level)
@deprecate set_level(f::Function, logger::Logger, level) setlevel!(f, logger, level)

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
    Base.depwarn("`add_handler(logger, handler[, name])` is being deprecated in favour of `push!(logger, handler)`", :add_handler)
    handler.levels.x = logger.levels
    logger.handlers[name] = handler
end

"""
    remove_handler(logger::Logger, name)

Removes the `Handler` with the provided name from the logger.handlers.
"""
function remove_handler(logger::Logger, name)
    Base.depwarn("`remove_handler(logger, name)` is being deprecated.", :remove_handler)
    delete!(logger.handlers, name)
end

# Handler deprecations
@deprecate filters(handler::DefaultHandler) getfilters(handler)
@deprecate add_filter(handler::DefaultHandler, filter::Memento.Filter) push!(handler, filter)
@deprecate set_level(handler::DefaultHandler, level::AbstractString) setlevel!(handler, level)

# END Memento 0.5 deprecations