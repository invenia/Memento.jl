"""
    Filter

A wrapper around a function that takes a log `Record` and returns
a bool indicating whether to log it.
`false` means "skip logging this record", similar to `Base.filter`. 

# Fields
`f::Function`: a function that should return a bool given a `Record`
"""
struct Filter
    f::Function
end

function (filter::Filter)(rec::Record)::Bool
    return filter.f(rec)
end
