using Base: @deprecate, @deprecate_binding
import Base: getindex

# BEGIN Memento 0.12 deprecations

@deprecate config(args...; kwargs...) config!(args...; kwargs...)
@deprecate_binding Test Memento.TestUtils false
@deprecate getindex(rec::T, attr::Symbol) where {T <: Record} getproperty(rec, attr) false

# END Memento 0.12 deprecations
