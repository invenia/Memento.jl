# Formatters

`Formatter`s describe how to take a `Record` and convert it into properly formatted string. Currently, there are two types of `Formatters`.

1. `DefaultFormatter` - use a simple template string format to map keys in the `Record` to places in the resulting string.
```julia
julia> DefaultFormatter("[{date} | {level} | {name}]: {msg}")
```

2. `JsonFormatter` - builds an appropriate formatted `Dict` from the `Record` in order to use `JSON.json(dict)` to produce the resulting string.
