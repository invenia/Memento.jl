# Introduction

## Logging levels

You can globally set the minimum logging level with `basic_config`.
```julia
julia>basic_config("debug")
```
Will log all messages for all loggers at or above "debug".
```julia
julia>basic_config("warn")
```
Will only log message at or above the "warn" level.

We can also set the logging level for specific loggers or collections of loggers if we explicitly set the level on an existing logger.
```julia
julia>set_level(get_logger("Main"), "info")
```
Will only set the logging level to "info" for the "Main" logger and any future children of the "Main" logger.

By default Memento has 9 logging levels.

Level | Number | Description
--- | --- | ---
not_set | 0 | Will not log anything, but may still propagate messages to its parents.
debug | 10 | Log verbose message used for debugging.
info | 20 | Log general information about a program.
notice | 30 | Log important events that are still part of normal execution.
warn | 40 | Log warning that may cause the program to fail.
error | 50 | Log errors and throw or rethrow an error.
critical | 60 | Entire application has crashed.
alert | 70 | The entire application crashed and is not recoverable. Probably need to wake up the sysadmin.
emergency | 80 | System is unusable. Applications shouldn't need to call this so it may be removed in the future.

## Formatting logs

The by default Memento will use a `DefaultFormatter` for handlers.
This `Formatter` takes a format string for mapping log record fields into each log message.
Desired fields are wrapped in curly brackets (ie: `"{msg}"`)

The default format string is `"[{level} | {name}]: {msg}"` would produce message that look like
```julia
[info | root]: my info message.
[warn | root]: my warning message.
...
```
However, you could change this string to just `"{level}: {msg}"` which would produce message that look like
```julia
info: my info message.
warn: my warning message.
...
```

The simplest way to globally change the log format is with `basic_config`
```julia
julia> basic_config("debug"; fmt="[{level} | {name}]: {msg}")
```

The following fields are available via the `DefaultRecord`.

Field | Description
--- | ---
date | The log event date rounded to seconds
level | The log event level as a string
levelnum | The integer value for the log event level
msg | The source log event message
name | The name of the source logger
pid | The pid where the log event occured
lookup | The top StackFrame of the stacktrace for the log event
stacktrace | A StackTrace for the log event

For more details on the `DefaultFormatter` and `DefaultRecord` please see the API docs.
More general information on `Formatter`s and `Record`s will be discussed later in this manual.

## Architecture

There are five main components of Memento.jl that you can manipulate:

1. Loggers
2. Handlers
3. Formatters
4. Records
5. IO

The remainder of this manual will discuss how you can use these components to customize Memento to you particular application.
