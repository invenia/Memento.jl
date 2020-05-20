# Public

## Configuration

```@docs
Memento.config!
Memento.register
Memento.reset!
```

## Loggers

```@docs
Logger
getlogger
log(::Logger, ::Record)
log(::Logger, ::AbstractString, ::AbstractString)
log(::Function, ::Logger, ::AbstractString)
getlevel(::Logger)
Memento.getlevels(::Logger)
setlevel!(::Logger, ::AbstractString)
setlevel!(::Function, ::Logger, ::AbstractString)
gethandlers
Base.push!(::Logger, ::Handler)
getfilters(::Logger)
push!(::Logger, ::Memento.Filter)
Memento.getpath
Memento.getchildren
isroot
isset
ispropagating
setpropagating!
setrecord!
trace
debug
info
notice
warn
error
critical
alert
emergency
```

## Handlers

```@docs
Handler
DefaultHandler
Escalator
log(::Handler, ::Record)
getlevel(::Handler)
getfilters(::Handler)
Memento.emit
setlevel!(::DefaultHandler, ::AbstractString)
push!(::DefaultHandler, ::Memento.Filter)
Memento.getlevels(::Handler)
Memento.setup_opts
```

## Formatters

```@docs
Formatter
DefaultFormatter
DictFormatter
format
```

## Records

```@docs
Record
Memento.getlevel(::Record)
DefaultRecord
Memento.Attribute
Memento.AttributeRecord
Base.get(::Memento.Attribute)
Base.Dict(::Record)
Memento.get_trace
Memento.get_lookup
```

## IO

```@docs
FileRoller
Memento.getfile
Memento.getsuffix
```

## Memento.TestUtils

```@docs
Memento.TestUtils.@test_log
Memento.TestUtils.@test_nolog
Memento.TestUtils.@test_warn
Memento.TestUtils.@test_throws
```

## Misc

```@docs
Memento.Filter
Memento.EscalationError
Memento.LoggerSerializationError
```
