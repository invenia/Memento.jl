module Test

using ..Memento
using Compat
using Compat.Test

import Compat.Test: @test_warn, @test_throws

export @test_log

# These function are just a copy of `ismatch_warn` on 0.6 or `contains_warn` on 0.7`.
# contains_msg(output, s) = contains_warn(output, s)
occursin_msg(s::AbstractString, output) = occursin(s, output)
occursin_msg(s::Regex, output) = occursin(s, output)
occursin_msg(s::Function, output) = s(output)
occursin_msg(S::Union{AbstractArray,Tuple}, output) = all(s -> occursin_msg(s, output), S)

"""
    @test_log(logger, level, msg, expr)

Adds a temporary test handler to the `logger` that checks for a record with the `level` and
`msg` before executing the `expr`. The handler is always removed after executing `expr`.
"""
macro test_log(logger, level, msg, expr)
    quote
        handler = TestHandler($(esc(level)), $(esc(msg)))
        handlers = copy(gethandlers($(esc(logger))))

        try
            $(esc(logger)).handlers = Dict{Any, Handler}()
            push!($(esc(logger)), handler)

            setpropagating!($(esc(logger)), false) do
                ret = $(esc(expr))
                @test handler.found[1] == $(esc(level))
                @test occursin_msg($(esc(msg)), handler.found[2])
                ret
            end
        finally
            $(esc(logger)).handlers = handlers
        end
    end
end

"""
    @test_warn(logger, msg, expr)

Convenience macro that calls `Memento.Test.@test_log(logger, "warn", msg, expr)`.
"""
macro test_warn(logger, msg, expr)
    quote
        @test_log($(esc(logger)), "warn", $(esc(msg)), $(esc(expr)))
    end
end

"""
    @test_throws(logger, extype, expr)

Disables the `logger` and calls `@test_throws extype, expr`.
"""
macro test_throws(logger, extype, expr)
    quote
        setlevel!($(esc(logger)), "not_set") do
            setpropagating!($(esc(logger)), false) do
                @test_throws $(esc(extype)) $(esc(expr))
            end
        end
    end
end

mutable struct TestHandler{F, O} <: Handler{F, O}
    level::String
    msg
    levels::Ref{Dict{AbstractString, Int}}
    found::Tuple
end

function TestHandler(level, msg)
    TestHandler{DefaultFormatter, IOBuffer}(
        String(level), msg, Ref(Memento._log_levels), ("", "")
    )
end

function Base.log(handler::TestHandler, rec::Record)
    # Uncomment the lines below to debug issues with the `TestHandler`
    # println(string("Record: ", rec[:level], ", ", rec[:msg]))
    # println(string("Search: ", handler.level, ", ", handler.msg))
    # println(string("Found: ", String(rec[:level]) == handler.level && occursin_msg(handler.msg, String(rec[:msg]))))

    if String(rec[:level]) == handler.level && occursin_msg(handler.msg, String(rec[:msg]))
        handler.found = (rec[:level], rec[:msg])
    end
end

end