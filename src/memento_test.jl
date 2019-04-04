module TestUtils

using ..Memento
using Test

import Test: @test_warn, @test_throws

export @test_log, @test_nolog

const EMPTY_MATCH = nothing

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
    @test_nolog(logger, level, msg, expr)

Adds a temporary test handler to the `logger` that checks that there was no log record with
the expected `level` and `msg` before executing the `expr`. The handler is always removed
after executing `expr`.
"""
macro test_nolog(logger, level, msg, expr)
    quote
        handler = TestHandler($(esc(level)), $(esc(msg)))
        handlers = copy(gethandlers($(esc(logger))))

        try
            $(esc(logger)).handlers = Dict{Any, Handler}()
            push!($(esc(logger)), handler)

            setpropagating!($(esc(logger)), false) do
                ret = $(esc(expr))
                @test handler.found[1] == EMPTY_MATCH && handler.found[2] == EMPTY_MATCH
                ret
            end
        finally
            $(esc(logger)).handlers = handlers
        end
    end
end


"""
    @test_warn(logger, msg, expr)

Convenience macro that calls `Memento.TestUtils.@test_log(logger, "warn", msg, expr)`.
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
    found::Tuple
end

function TestHandler(level, msg)
    TestHandler{DefaultFormatter, IOBuffer}(
        String(level), msg, (EMPTY_MATCH, EMPTY_MATCH)
    )
end

function Base.log(handler::TestHandler, rec::Record)
    level = getlevel(rec)

    # Uncomment the lines below to debug issues with the `TestHandler`
    # println(string("Record: ", level, ", ", rec.msg))
    # println(string("Search: ", handler.level, ", ", handler.msg))
    # println(string("Found: ", level == handler.level && occursin_msg(handler.msg, String(rec.msg))))

    if level == handler.level && occursin_msg(handler.msg, String(rec.msg))
        handler.found = (level, rec.msg)
    end
end

end
