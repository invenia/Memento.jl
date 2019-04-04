# [Handlers](@id man_handlers)

As we've already seen, `Handler`s can be used to write log messages to different IO types. More specifically, handlers are parameterized types that describe the relationship of how `Formatter` and `IO` types are used to take a `Record` (a kind of specified `Dict`) -> convert it to a `String` with the `Formatter` and write that to an `IO` type.

In the simplest case a `Handler` definition would like:
```julia
mutable struct MyHandler{F<:Formatter, O<:IO} <: Handler{F, O}
    fmt::F
    io::O
end

function emit(handler::MyHandler{F, O}, rec::Record) where {F<:Formatter, O<:IO}
    str = Memento.format(handler.fmt, rec)
    println(handler.io, str)
    flush(handler.io)
end
```

However, under some circumstances it may be necessary to customize this
behaviour based on the `Formatter`, `IO` or `Record` types being used.
For example, if you'd like to use the `Syslog` `IO` type from
[Syslogs.jl](https://github.com/invenia/Syslogs.jl) you'll need topass in an extra `level`
argument to its `println` so we special case this like so:
```julia
using Syslogs

function emit(handler::MyHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}
    str = Memento.format(handler.fmt, rec)
    println(handler.io, rec.level, str)
    flush(handler.io)
end
```
