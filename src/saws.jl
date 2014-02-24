
# -------

date_saw(args::Dict) = push!(args, :date, now())

function fn_call_saw(args::Dict)
    lookup = [ccall(:jl_lookup_code_address,
                    Any,
                    (Ptr{Void}, Int32), b, 0) for b in backtrace()]

    filter!(l->!isempty(l) &&
            !any(symb->symb == l[1],
                 [:fn_call_saw, :log, :info, :warn, :debug]),lookup)
    if isempty(lookup)
        args
    else
        # lookup is a tuple
        push!(args, :lookup, lookup[1])
    end
end

# -------
