# Producing JSON logs?

In Memento v0.4, the `JsonFormatter` type was converted into a more general [`DictFormatter`](@ref)
which allowed us to drop [JSON.jl](https://github.com/JuliaIO/JSON.jl) as a dependency.
However, the original behaviour can still be easily achieved by passing in `JSON.json` to the
[`DictFormatter`](@ref) constructor.

```julia
using JSON

add_handler(
    logger,
    DefaultHandler(
        "json-output.log",
        DictFormatter(JSON.json)
    ),
    "JSON"
)
```
