# Using Memento in Julia packages?

Some care needs to be taken when working with Memento from [precompiled modules](https://docs.julialang.org/en/latest/manual/modules/#Module-initialization-and-precompilation-1).
Specifically, it is important to note that if you want folks be able to configure your logger from outside the module you'll want to register the logger in your `__init__()` method.

```julia
module MyModule

using Memento  # requires a minimum of Memento 0.5

# Create our module level logger (this will get precompiled)
const LOGGER = getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `get_logger(MyModule)`
# NOTE: If this line is not included then the precompiled `MyModule.LOGGER` won't be registered at runtime.
function __init__()
    Memento.register(LOGGER)
end

end
```
