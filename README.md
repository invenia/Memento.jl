Lumberjack.jl
=============

## Quick Start
```julia
Pkg.clone("https://github.com/forio/Lumberjack.jl.git")
```

```julia
using Lumberjack

julia> log("debug", "something innocuous happened!")
2013-12-02T19:39:16 UTC debug:"something innocuous happened!"

julia> log("info", "using some more memory...", {:mem_allocated => 9001, :mem_left => 22})
2013-12-02T19:39:21 UTC info:"using some more memory..." mem_allocated:9001 mem_left:22

julia> log("warn", "running really low on memory...", {:mem_left => "22 k"})
2013-12-02T19:39:44 UTC warn:"running really low on memory..." mem_left:"22 k"

julia> log("error", "OUT OF MEMORY - IT'S ALL OVER - ARRGGGHHHH")
2013-12-02T19:39:48 UTC error:"OUT OF MEMORY - IT'S ALL OVER - ARRGGGHHHH"
```

## Architecture

There are three main components of Lumberjack.jl that you can manipulate and use to produce the logs you've always dreamed of.

### LumberMill

A lumber mill holds information needed to manage the whole process of creating and storing logs. There is a global `_lumber_mill` inside the `Lumberjack` module and, in all likelyhood, you wont need to create another. All exported api methods that accept a `LumberMill` will be overloaded to use `_lumber_mill` by default.

### Saw functions

A saw function simply takes in a dict of parameters, adds or removes things, and then returns the dict back. By default, the `date_saw` is applied to logs that come in and appends `date => DateTime.now()`.

### TimberTruck

Timber trucks are used to send logs to their final destinations (files, the console, etc). A timber truck ingerits from the abstarct type `TimberTruck` and overloads the `log(t::TimberTruck, args::Dict)` function. By default, the framework will create a `LumberjackLog` truck that will print `args` as a string of `key:"value"` pairs to STDOUT.
