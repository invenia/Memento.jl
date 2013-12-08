Lumberjack.jl
=============
[![Build Status](https://magnum.travis-ci.com/forio/Lumberjack.jl.png?token=g2BATAK3ptx7LojqfRxq&branch=master)](https://magnum.travis-ci.com/forio/Lumberjack.jl)

## Quick Start
```julia
Pkg.clone("https://github.com/forio/Lumberjack.jl.git")
```

### Create logs
```julia
using Lumberjack

julia> log("debug", "something innocuous happened!")
2013-12-02T19:39:16 UTC - debug:"something innocuous happened!"

julia> log("info", "using more memory!", {:mem_allocated => 9001, :mem_left => 22})
2013-12-02T19:39:21 UTC - info:"using more memory!" mem_allocated:9001 mem_left:22

julia> log("warn", "running really low on memory...", {:mem_left => "22 k"})
2013-12-02T19:39:44 UTC - warn:"running really low on memory..." mem_left:"22 k"

julia> log("error", "OUT OF MEMORY - IT'S ALL OVER - ARRGGGHHHH")
2013-12-02T19:39:48 UTC - error:"OUT OF MEMORY - IT'S ALL OVER - ARRGGGHHHH"
```

### Add and remove `TimberTrucks`
Logs are brought to different output streams by `TimberTrucks`. To create a truck that will dump logs into a file, simply:
```julia
julia> Lumberjack.add_truck(LuberjackTruck("mylogfile.log"), "my-file-logger")
```
Now there is a truck named "my-file-logger", and it will write all of your logs to `mylogfile.log`. Your logs will still show up in the console, however, because -by default- there is a truck named "console" already hard at work. Remove it by calling:
```julia
julia> Lumberjack.remove_truck("console")
```

## Architecture

There are three main components of Lumberjack.jl that you can manipulate:

### LumberMill

A lumber mill holds information needed to manage the whole process of creating and storing logs. There is a global `_lumber_mill` inside the `Lumberjack` module and, in all likelyhood, you wont need to create another. All exported api methods that accept a `LumberMill` will be overloaded to use `_lumber_mill` by default.

### Saw functions

A saw function simply takes in a dict of parameters, adds or removes things, and then returns the dict back. By default, the `date_saw` is applied to logs that come in and appends `date => DateTime.now()`.

### TimberTruck

Timber trucks are used to send logs to their final destinations (files, the console, etc). A timber truck ingerits from the abstarct type `TimberTruck` and overloads the `log(t::TimberTruck, args::Dict)` function. By default, the framework will create a `LumberjackLog` truck that will print `args` as a string of `key:value` pairs to STDOUT.


## API

### Logging
```julia
log(lm::LumberMill, mode::String, msg::String, args::Dict)
```
+ `mode` is a string like "debug", "info", "warn", "error", etc
+ `msg` is an explanative message about what happened
+ `args` is an optional dictionary of data to be recorded alongside `msg`


### Saws
```julia
add_saw(lm::LumberMill, saw_fn::Function, index)
```
+ `index` is optional and will default to the end of the saw list


```julia
remove_saw(lm::LumberMill, index)
```
+ `index` is optional, by default the last saw in the list will be removed


```julia
remove_saws(lm::LumberMill)  # removes ALL saws currently in use
```


### Trucks
```julia
add_truck(lm::LumberMill, truck::TimberTruck, name)
```
+ `name` is optional and will default to a unique id


```julia
remove_truck(lm::LumberMill, name)
```
+ `name` is the id associated with the truck to be removed


```julia
remove_trucks(lm::LumberMill)  # removes ALL trucks currently in use
```


### Configuration
```julia
configure(lm::LumberMill; modes = ["debug", "info", "warn", "error"])
```
+ `modes` is an ordered array of logging levels
