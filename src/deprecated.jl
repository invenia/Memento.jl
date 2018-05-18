@deprecate config(args...; kwargs...) config!(args...; kwargs...)

@deprecate Attribute(T::Type, f::Function) Attribute{T}(f)
