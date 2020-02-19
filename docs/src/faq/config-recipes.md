# Configuring Logging in Applications?(@id config_recipes)

So we've provide examples of many different ways that Memento.jl can be extended, but what are some common examples for configuring Memento out of the box, without extending any components.

## Logging to a File

I want all my log message coming from `MyPkg` to be saved to a local file. Easy, just add a `DefaultHandler` with the desired filename to the specific child logger.

```julia
push!(getlogger("MyPkg"), DefaultHandler("noisy.log"))
```

If you want `trace` and `debug` level logging as well then just set the level on that logger.

```julia
setlevel!(getlogger("MyPkg"), "trace")
```

This will send trace messages to all handlers attached to the `MyPkg` logger, but these want be emitted from the root logger where the default level is `info`.

## Silence Loggers

Have some noisy dependencies that you'd like to silence? Maybe the package owner needs to make some `info` messages `debug` only? Until that's fixed you can always silence `info` logs from the package in you application.

```julia
setlevel!(getlogger("NoisyPkg"), "notice")
```

All `trace`, `debug` and `info` messages from `NoisyPkg` and submodules will no longer propagate to the root logger and emit logs to the console.


## Selective Debugging

Found a bug and need to enable selective debug logging around where the error occurs? There are two ways you can do this in Memento.
The simplest option is to call `setlevel!` for all loggers along the desired path.

```julia
setlevel!.(Memento.getpath(getlogger("MyPkg")), "debug")
```

In this example, `Logger(root)` and `Logger(MyPkg)` are now set to `debug`, and debugging messages will propagate along that path to the root default handler.

Pros:
- Reuses the root default handler
- Single line of code
- Enables debug logging for related loggers (e.g., parents)

Cons:
- May produce too much noisy if you don't want debug message from parents.

Alternatively, if you want only debug level messages for a specific logger and you don't want any extra logs from the parents then you'll need to modify that logger's level and add a custom handler.

```julia
mypkg_logger = getlogger("MyPkg")
setlevel!(mypkg_logger, "debug")
handler = DefaultHandler(
    stdout,
    DefaultFormatter("[{date} | {level} | {name}]: {msg}")
)
push!(mypkg_logger, handler)
```

This will log all debug or higher messages to this new custom handler.

NOTE: This may result in duplicate logs as the custom handler will emit `info`, `notice`, `warn`, etc logs, but those will also propagate up to the root logger. To avoid this you may wish to add a custom filter to your custom handler to only log debug messages.

```julia
push!(handler, Memento.Filter(r -> getlevel(rec) == "debug"))
```

Pros:
- Fine grained control over debug message handling
- Flexible filtering options

Cons:
- Verbose
- Requires greater understanding of the logger hierarchy and record propagation
