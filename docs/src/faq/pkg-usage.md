# Using Memento in Julia packages?

Some care needs to be taken when working with Memento from [precompiled modules](https://docs.julialang.org/en/stable/manual/modules/#module-initialization-and-precompilation).
Specifically, it is important to note that if you want folks be able to configure your logger from outside the module you'll want to register the logger in your `__init__()` method.

```julia
__precompile__() # this module is safe to precompile
module MyModule

using Memento

# Create our module level logger (this will get precompiled)
const LOGGER = get_logger(current_module())   # or `get_logger(@__MODULE__)` on 0.7

# Register the module level logger at runtime so that folks can access the logger via `get_logger(MyModule)`
# NOTE: If this line is not included then the precompiled `MyModule.LOGGER` won't be registered at runtime.
__init__() = Memento.register(LOGGER)

end
```