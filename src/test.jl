module Test

using ..Memento
using Compat.Test

export @test_log

mutable struct TestHandler{F, O} <: Handler{F, O}
    filters::AbstractVector{Memento.Filter}
    levels::Ref{Dict{AbstractString, Int}}
    found::Bool
end

function TestHandler(level, msg)
        TestHandler{DefaultFormatter, IOBuffer}(
            [
                Memento.Filter(rec -> rec[:level] == String(level)),
                Memento.Filter(rec -> rec[:msg] == String(msg))
            ],
             Ref(Memento._log_levels),
            false
        )
    end

function Base.log(handler::TestHandler, rec::Record)
    handler.found = all(f -> f(rec), handler.filters)
end

macro test_log(logger, level, msg, expr)
    quote
        handler = TestHandler($level, $msg)
        add_handler($(esc(logger)), handler, "TestHandler")

        try
            ret = $(esc(expr))
            @test handler.found
            ret
        finally
            remove_handler($(esc(logger)), "TestHandler")
        end
    end
end

end