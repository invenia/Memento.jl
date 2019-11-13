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
occursin_msg(s, ::Nothing) = false  # Fallback, but shouldn't be needed

"""
    @test_log(logger, level, msg, expr)

Test that the expression `expr` emits a record in the `logger` with the specified `level`
string and contains the `msg` string or matches the `msg` regular expression.
If `msg` is a boolean function, tests whether `msg(output)` returns true.
If `msg` is a tuple or array, checks that the output contains/matches each item in `msg`.
Returns the result of evaluating `expr`.

This will temporarily add a test handler to the `logger` which will always be removed after
executing the expression.

See also [`@test_nolog`](@ref) to check for the absence of a record.

## Example
```jldoctest
julia> using Memento, Memento.TestUtils

julia> logger = getlogger("test_log");

julia> m = "Hello World!";

julia> @test_log logger "info" "Hello" info(logger, m)

julia> @test_log logger "info" r"^Hello" info(logger, m)

julia> @test_log logger "info" ("Hello", r"World!\$") info(logger, m)  # All elements occursin
```
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

                @test(
                    handler.found[1] == $(esc(level)) &&
                    occursin_msg($(esc(msg)), handler.found[2])
                )
                ret
            end
        finally
            $(esc(logger)).handlers = handlers
        end
    end
end

"""
    @test_nolog(logger, level, msg, expr)

Test that the expression `expr` does not emit a record in the `logger` with the specified
`level` string containing the `msg` string or matching the `msg` regular expression.

See also [`@test_log`](@ref) for further details.
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

Convenience macro that calls [`@test_log(logger, "warn", msg, expr)`](@ref @test_log).
"""
macro test_warn(logger, msg, expr)
    quote
        @test_log($(esc(logger)), "warn", $(esc(msg)), $(esc(expr)))
    end
end

"""
    @test_throws(logger, extype, expr)

Disables the `logger` and calls [`@test_throws extype expr`](https://docs.julialang.org/en/v1/stdlib/Test/#Test.@test_throws).
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
