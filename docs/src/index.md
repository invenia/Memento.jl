# Memento.jl

[![Build Status](https://travis-ci.org/invenia/Memento.jl.svg?branch=master)](https://travis-ci.org/invenia/Memento.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/1agvguwqkae06qr9/branch/master?svg=true)](https://ci.appveyor.com/project/Rory-Finnegan/memento-jl/branch/master)
[![codecov](https://codecov.io/gh/invenia/Memento.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/invenia/Memento.jl)

Memento is flexible hierarchical logging library for julia.

## Installation

```julia
julia> Pkg.add("Memento")
```

## Quick Start

Start by `using` Memento

```julia
julia> using Memento
```

Now setup basic logging on the root logger with [`Memento.config!`](@ref).

```julia
julia> logger = Memento.config!("debug"; fmt="[{level} | {name}]: {msg}")
Logger(root)
```

Now start logging with the root logger.

```julia
julia> debug(logger, "Something to help you track down a bug.")
[debug | root]: Something to help you track down a bug.

julia> info(logger, "Something you might want to know.")
[info | root]: Something you might want to know.

julia> notice(logger, "This is probably pretty important.")
[notice | root]: This is probably pretty important.

julia> warn(logger, "This might cause an error.")
[warn | root]: This might cause an error.

julia> warn(logger, ErrorException("A caught exception that we want to log as a warning."))
[warn | root]: A caught exception that we want to log as a warning.

julia> error(logger, "Something that should throw an error.")
[error | root]: Something that should throw an error.
ERROR: Something that should throw an error.
 in error(::Memento.Logger, ::String) at /Users/rory/.julia/v0.5/Memento/src/loggers.jl:250
```

Now maybe you want to have a different logger for each module/submodule.
This allows you to have custom logging behaviour and handlers for different modules and provides easier to parse logging output.

```julia
julia> child_logger = getlogger("Foo.bar")
Logger(Foo.bar)

julia> setlevel!(child_logger, "warn")
"warn"

julia> push!(child_logger, DefaultHandler(tempname(), DefaultFormatter("[{date} | {level} | {name}]: {msg}")))

Memento.DefaultHandler{Memento.DefaultFormatter,IOStream}(Memento.DefaultFormatter("[{date} | {level} | {name}]: {msg}"),IOStream(<file /var/folders/_6/25myjdtx2fxgjvznn19rp22m0000gn/T/julia8lonyA>),Dict{Symbol,Any}(Pair{Symbol,Any}(:is_colorized,false)))

julia> debug(child_logger, "Something that should only be printed to STDOUT on the root_logger.")
[debug | Foo.bar]: Something that should only be printed to STDOUT on the root_logger.

julia> warn(child_logger, "Warning to STDOUT and the log file.")
[warn | Foo.bar]: Warning to STDOUT and the log file.
```

NOTE: We used `getlogger("Foo.bar")`, but you can also do `getlogger(current_module())` which allows us to avoid hard coding in logger names.

## Piggybacking onto another package's logger

To add logging events using another package's logger in your own module/package you can do:

```julia
module MyModule

using OtherPackage
using Memento

# Set package logger to be available for configuration at runtime
function __init__()
    global LOGGER = getlogger("OtherPackage")
end

function my_func()
    warn(LOGGER, "MyModule warning")
end

end  # MyModule
```
