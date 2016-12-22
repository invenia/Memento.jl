Lumberjack.jl
=============

[![Build Status](https://travis-ci.org/invenia/Lumberjack.jl.svg?branch=master)](https://travis-ci.org/invenia/Lumberjack.jl)
[![codecov](https://codecov.io/gh/invenia/Lumberjack.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Lumberjack.jl)


## Quick Start
```julia
Pkg.add("Lumberjack")
```

### Create logs
```julia
julia> using Lumberjack

julia> debug(logger, "Something that won't get logged.")

julia> info(logger, "Something you might want to know.")
[2016-12-21T22:09:34 | info | Main]: Something you might want to know.

julia> warn(logger, "This might cause an error.")
[2016-12-21T22:10:50 | warn | Main]: This might cause an error.

julia> warn(logger, ErrorException("A caught exception that we want to log as a warning."))
[2016-12-21T22:11:26 | warn | Main]: A caught exception that we want to log as a warning.

julia> error(logger, "Something that should throw an error.")
[2016-12-21T22:11:55 | error | Main]: Something that should throw an error.
ERROR: Something that should throw an error.
 in error(::Lumberjack.Logger, ::String) at ...
```

### Add and remove Handlers
Logs are brought to different output streams by `Handlers`. To create a handler that will dump logs into a file, simply:
```julia
julia> add_handler(logger, DefaultHandler("mylogfile.log"), "file-logging")
```
Now there is a handler named "file-logging", and it will write all of your logs to `mylogfile.log`. Your logs will still show up in the console, however, because -by default- there is a handler named "console" already hard at work. Remove it by calling:
```julia
julia> remove_handler(logger, "console")
```
The above will only add and remove handlers for the current logger and other existing loggers will be unaffected.

### Manage logging levels

* Level & Levels for a Logger


#### is_colorized
Colors can be added enabled using the following:

```julia
julia> add_handler(logger, DefaultHandler(
    STDOUT, DefaultFormatter(),
    Dict{Symbol, Any}(:is_colorized => true)),
    "console"
)
```

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

#### colors
Custom colors/log levels can also be specified:
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

## Architecture

There are four main components of Lumberjack.jl that you can manipulate:

### Logger

A logger holds information needed to manage the whole process of creating and storing logs. There is a default "root" logger stored in global `_loggers` inside the `Lumberjack` module. Since Lumberjack implements hierarchical logging you should define child loggers that can be configured independently and better describe the individual components within your code.

### Formatters

N/A

### Records

N/A

### IO

N/A

### Handlers

N/A


## API

TODO: autogenerate and a place in a docs folder


### Syslog and Stack Trace Example

Please note that syslog output is only available on systems that have `logger` utility installed. (This should include both Linux and OS X, but typically excludes Windows.)

Examples: N/A

The info message is missing because we set our truck to only output logs at warning level and above.

Note that BSD's `logger` (used on OS X) will append a second process ID, which is the PID of the `logger` tool itself.
