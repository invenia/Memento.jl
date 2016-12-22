Memento.jl
=============

[![Build Status](https://travis-ci.org/invenia/Memento.jl.svg?branch=master)](https://travis-ci.org/invenia/Memento.jl)
[![codecov](https://codecov.io/gh/invenia/Memento.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Memento.jl)

Memento is flexible hierarchical logging library for julia.

## Installation

```julia
julia> Pkg.add("Memento")
```

## Quick Start

![quickstart](docs/img/quickstart.png)


## Architecture

There are five main components of Memento.jl that you can manipulate:

### Logger

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

### Handlers

As we've already seen, `Handler`s can be used to write log messages to different IO types. More specifically, handlers are parameterized types that describe the relationship of how `Formatter` and `IO` types are used to take a `Record` (a kind of specified `Dict`) -> convert it to a `String` with the `Formatter` and write that to an `IO` type.

In the simplest case a `Handler` definition would like:
```julia
type MyHandler{F<:Formatter, O<:IO} <: Handler{F, O}
    fmt::F
    io::O
end

function log{F<:Formatter, O<:IO}(handler::MyHandler{F, O}, rec::Record)
    str = format(handler.fmt, rec)
    println(handler.io, str)
    flush(handler.io)
end
```

However, under some circumstances it may be necessary to customize this
behaviour based on the `Formatter`, `IO` or `Record` types being used.
For example, the `Syslog` `IO` type needs an extra `level` argument to
its `println` so we special case this like so:
```julia
function log{F<:Formatter, O<:Syslog}(handler::MyHandler{F, O}, rec::Record)
    str = format(handler.fmt, rec)
    println(handler.io, rec[:level], str)
    flush(handler.io)
end
```

### Formatters

`Formatter`s describe how to take a `Record` and convert it into properly formatted string. Currently, there are two types of `Formatters`.

1. `DefaultFormatter` - use a simple template string format to map keys in the `Record` to places in the resulting string.
```julia
julia> DefaultFormatter("[{date} | {level} | {name}]: {msg}")
```

2. `JsonFormatter` - builds an appropriate formatted `Dict` from the `Record` in order to use `JSON.json(dict)` to produce the resulting string.

### Records

`Record`s describe a set of key value pairs that should be available to a  `Formatter` on every log message. While the `DefaultRecord` in Memento provides many of the keys and values need for most logging applications, you may need to implement your own `Record` type.

Internal `DefaultRecord` Dict:
```julia
Dict(
    :date => round(now(), Base.Dates.Second),
    :level => args[:level],
    :levelnum => args[:levelnum],
    :msg => args[:msg],
    :name => args[:name],
    :pid => myid(),
    :lookup => isempty(trace) ? nothing : first(trace),
    :stacktrace => trace,
)
```

### IO

Memento writes all logs to any subtype of `IO` including `IOBuffer`s, `LibuvStream`s, `Pipe`s, `File`s, etc. Memento also comes with 2 logging specific `IO` types.

1. `FileRoller` - Does automatic log file rotation.
2. `Syslog` - Write to syslog using the `logger` command. Please note that syslog output is only available on systems that have `logger` utility installed. (This should include both Linux and OS X, but typically excludes Windows.) Note that BSD's `logger` (used on OS X) will append a second process ID, which is the PID of the `logger` tool itself.

To create your own `IO` types you need to subtype `IO` and implement the `println` and `flush` methods.


## FAQ

### How do I set logging levels?

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

### How do I change the colors?

Colors can be enabled/disabled and set using via the `is_colorized` and `colors` options to the `DefaultHandler`.
```julia
julia> add_handler(logger, DefaultHandler(
    STDOUT, DefaultFormatter(),
    Dict{Symbol, Any}(:is_colorized => true)),
    "console"
)
```
Will create a `DefaultHandler` with colorization

By default the following colors are used:
```julia
Dict{AbstractString, Symbol}(
    "debug" => :blue,
    "info" => :green,
    "notice" => :cyan,
    "warn" => :magenta,
    "error" => :red,
    "critical" => :yellow,
    "alert" => :white,
    "emergency" => :black,
)
```

However, you can specify custom colors/log levels like so:
```julia
add_handler(logger, DefaultHandler(
    STDOUT, DefaultFormatter(),
    Dict{Symbol, Any}(
        :colors => Dict{AbstractString, Symbol}(
            "debug" => :black,
            "info" => :blue,
            "warn" => :yellow,
            "error" => :red,
            "crazy" => :green
        )
    ),
    "console"
)
```
You can also globally disable colorization when running `basic_config`
```julia
julia> basic_config("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
```

## API

TODO: autogenerate and a place in a docs folder
