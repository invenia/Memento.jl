# Loggers

A `Logger` is the primary component you use to send formatted log messages to various IO outputs. This type holds information needed to manage the process of creating and storing logs. There is a default "root" logger stored in global `_loggers` inside the `Memento` module. Since Memento implements hierarchical logging you should define child loggers that can be configured independently and better describe the individual components within your code.
To create a new logger for you code it is recommended to do `get_logger(current_module())`.

```julia
julia> logger = get_logger(current_module())
```

Log messages are brought to different output streams by `Handlers`. From here you can add and remove handlers. To add a handler that writes to rotating log files, simply:

```julia
julia> add_handler(logger, DefaultHandler("mylogfile.log"), "file-logging")
```

Now there is a handler named "file-logging", and it will write all of your logs to `mylogfile.log`. Your logs will still show up in the console, however, because -by default- there is a handler named "console" already hard at work. Remove it by calling:

```julia
julia> remove_handler(logger, "console")
```

The operations presented here will only apply to the current logger, leaving existing loggers (e.g., `Logger(root)`) unaffected. However, any child loggers of `Logger(Main)` (e.g., `Logger(Main.Foo)` will have both the "console" and "file-logging" handlers available to it.

We can also set the level and `Record` type for our logger.
```julia
julia> set_level(logger, "warn")
```
Now we won't log any messages with this logger unless they are at least warning messages.
```julia
julia> set_record(logger, MyRecord)
```
Now our logger will call create `MyRecord`s instead of `DefaultRecord`s
