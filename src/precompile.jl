function _precompile_()
    # Precompiling this one methods seems to cut our allocations during package loading in half.
    @assert precompile(Tuple{typeof(Base.log), Memento.Logger, Memento.DefaultRecord})
end
