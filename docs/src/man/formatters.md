# [Formatters](@id man_formatters)

`Formatter`s describe how to take a `Record` and convert it into properly formatted string. Currently, there are two types of `Formatters`.

1. `DefaultFormatter`: use a simple template string format to map keys in the `Record` to places in the resulting string. (ie: `DefaultFormatter("[{date} | {level} | {name}]: {msg}")`

2. `DictFormatter`: builds an appropriately formatted `Dict` from the `Record` so that it can be serialized to a string with various formats. (e.g., `string`, `JSON.json`).

You should only need to write a custom `Formatter` type if you're needing to produce very specific string formats regardless of the `Record` type being used.
For example, we may want a `CSVFormatter` which always writes logs in a CSV Format.

If you just need to customize the behaviour of an existing `Formatter` to a specific `Record` type then you should simply overload the `format` method for that `Formatter`.

## Example

```julia
function Memento.format(fmt::DefaultFormatter, rec::MyRecord)
    ...
end
```
