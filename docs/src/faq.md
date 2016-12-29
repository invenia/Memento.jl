# FAQ

## Table of Contents

- [Why another logging library for julia?](#why-another-logging-library-for-julia)
- [How do I set logging levels?](#how-do-i-set-logging-levels)
- [How do I change the colors?](#how-do-i-change-the-colors)

### Why another logging library for Julia?
_...or why did you fork [Lumberjack.jl](https://github.com/WestleyArgentum/Lumberjack.jl)?_

The short answer is that none of the existing logging libraries quite fit our requirements.
The summary table provided below shows that all of the existing libraries are missing more than 1 requirement.
Our initial goal was to add more tests, hierarchical logging and some API changes to Lumberjack as it seemed to have the best balance of features and test coverage.
In the end, our changes diverged enough from Lumberjack that it made more sense to fork the project.

Library | Hierarchical | Custom Formatting | Custom IO Types | Syslog | Color | Coverage | Version
--- | --- | --- | --- | --- | --- | --- | ---
[Logging.jl](https://github.com/kmsquire/Logging.jl) | [Kinda](https://github.com/colinfang/MiniLogging.jl#why-another-logging-package) | No | Yes | Yes | Yes | 61% | 0.3.1
[Lumberjack.jl](https://github.com/WestleyArgentum/Lumberjack.jl) | No | [Kinda](https://github.com/WestleyArgentum/Lumberjack.jl#timbertruck) | Yes | Yes | Yes | 76% | 2.1.0
[MiniLogger.jl](https://github.com/colinfang/MiniLogging.jl) | Yes | No | Yes | No | No | 87% | 0.0.2
[Memento.jl](https://github.com/invenia/Memento.jl) | Yes | Yes | Yes | Yes | Yes | 100% | N/A

You can see from the table that Memento covers all of our logging requirements and has significantly higher test coverage.

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
