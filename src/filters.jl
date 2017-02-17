immutable Filter
    f::Function
end

function (filter::Filter)(rec::Record)::Bool
    return filter.f(rec)
end
