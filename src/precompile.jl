function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    # Memento
    @assert precompile(Core.kwfunc(Memento.config!), (Vector{Any}, typeof(Memento.config!), String))
    @assert precompile(Core.kwfunc(Memento.config!), (Vector{Any}, typeof(Memento.config!), String, String))
    @assert precompile(Core.kwfunc(Memento.config!), (Vector{Any}, typeof(Memento.config!), Memento.Logger, String))
    @assert precompile(Tuple{typeof(Memento._log), Memento.Logger, String, String})
    @assert precompile(Tuple{typeof(Memento.config!), String})
    @assert precompile(Tuple{typeof(Memento.getlogger), String})
    @assert precompile(Tuple{typeof(Memento.getpath), Memento.Logger})
    @assert precompile(Tuple{typeof(Memento.isroot), Memento.Logger})
    @assert precompile(Tuple{typeof(Memento.register), Memento.Logger})

    # Unknown
    @assert precompile(Tuple{Type{Memento.DefaultHandler{F, O} where O<:IO where F}, Base.TTY, Memento.DefaultFormatter, Base.Dict{Symbol, Any}})
    @assert precompile(Tuple{Type{Memento.DefaultRecord}, String, String, Int64, String})

    # Base
    @assert precompile(Tuple{typeof(Base.all), typeof(identity), Array{Memento.Filter, 1}})
    @assert precompile(Tuple{typeof(Base.get), Memento.Attribute{String}})
    @assert precompile(Tuple{typeof(Base.log), Memento.Logger, Memento.DefaultRecord})
    @assert precompile(Tuple{typeof(Base.print), Base.GenericIOBuffer{Array{UInt8, 1}}, Memento.Logger})
    @assert precompile(Tuple{typeof(Base.print_to_string), Memento.Logger, Int})
    @assert precompile(Tuple{typeof(Base.reverse!), Array{Memento.Logger, 1}, Int64, Int64})
    @assert precompile(Tuple{typeof(Base.setindex!), Array{Memento.Logger, 1}, Memento.Logger, Int64})
    @assert precompile(Tuple{typeof(Base.setindex!), Base.Dict{Any, Memento.Handler{F} where F<:Memento.Formatter}, Memento.DefaultHandler{Memento.DefaultFormatter, Base.TTY}, String})
    @assert precompile(Tuple{typeof(Base.show), Base.GenericIOBuffer{Array{UInt8, 1}}, Memento.Logger})

    # Manual
    @assert precompile(Tuple{typeof(Base.log), Memento.Logger, String, String})
    @assert precompile(Tuple{typeof(Memento.trace), Memento.Logger, String})
    @assert precompile(Tuple{typeof(Memento.debug), Memento.Logger, String})
    @assert precompile(Tuple{typeof(Memento.info), Memento.Logger, String})
    @assert precompile(Tuple{typeof(Memento.warn), Memento.Logger, String})
    @assert precompile(Tuple{typeof(Base.getindex), Base.Dict{AbstractString, Memento.Logger}, String})
end
