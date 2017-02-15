immutable LogFilter
    f::Function
end

Filter(f::Function) = LogFilter(f)

function (filter::LogFilter)(rec::Record)::Bool
    return filter.f(rec)
end
