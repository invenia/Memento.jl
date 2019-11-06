# Changing colors?

Colors can be enabled/disabled and set using via the `is_colorized` and `colors` options to the `DefaultHandler`.

```julia
julia> push!(logger, DefaultHandler(
    stdout, DefaultFormatter(),
    Dict{Symbol, Any}(:is_colorized => true))
)
```
will create a `DefaultHandler` with colorization.

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
push!(logger, DefaultHandler(
    stdout, DefaultFormatter(),
    Dict{Symbol, Any}(
        :colors => Dict{AbstractString, Symbol}(
            "debug" => :black,
            "info" => :blue,
            "warn" => :yellow,
            "error" => :red,
            "crazy" => :green
        )
    )
)
```

You can also globally disable colorization when running [`Memento.config!`](@ref)

```julia
julia> Memento.config!("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
```
