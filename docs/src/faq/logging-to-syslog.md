# Logging to Syslog?

In Memento v0.4, the builtin `Syslog` type was moved into its own package [Syslogs.jl](https://github.com/invenia/Syslogs.jl) which allows folks to use either Syslogs.jl or Memento.jl independently from one another.
Unfortunately, this does require the following bit of glue code in your projects.

```julia
# Load up `Syslogs.jl` where `Syslog` will be exported by default.
using Syslogs

# Define a 2 line glue method as the `Syslog` type requires a level argument be passed into
# the `println` method.
function Memento.emit(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}
    println(handler.io, rec.level, format(handler.fmt, rec))
    flush(handler.io)
end

# NOTE: This glue code is only necessary because Julia (as of v0.7) doesn't provide a good
# mechanism for handling optional dependencies.
```

Now we can start logging to syslog locally:

```julia
add_handler(
    logger,
    DefaultHandler(
        Syslog(),
        DefaultFormatter("{level}: {msg}")
    ),
    "Syslog"
)
```

We can also log to remote syslog servers via UDP or TCP:

```julia
add_handler(
    logger,
    DefaultHandler(
        Syslog(ip"123.34.56.78"),
        DefaultFormatter("{level}: {msg}")
    ),
    "Syslog"
)
```
