module Test

using ..Memento
using Compat.Test

import Compat.Test: @test_warn, @test_throws

export @test_log

"""
    @test_log(logger, level, msg, expr)

Adds a temporary test handler to the `logger` that checks for a record with the `level` and
`msg` before executing the `expr`. The handler is always removed after executing `expr`.
"""
macro test_log(logger, level, msg, expr)
    quote
        handler = TestHandler($(esc(level)), $(esc(msg)))
        handlers = copy(gethandlers($(esc(logger))))
        push!($(esc(logger)), handler)

        try
            ret = $(esc(expr))
            @test handler.found == (String($(esc(level))), String($(esc(msg))))
            ret
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
            @test_throws $(esc(extype)) $(esc(expr))
        end
    end
end

mutable struct TestHandler{F, O} <: Handler{F, O}
    level::String
    msg::String
    levels::Ref{Dict{AbstractString, Int}}
    found::Tuple
end

function TestHandler(level, msg)
    TestHandler{DefaultFormatter, IOBuffer}(
        String(level),
        String(msg),
        Ref(Memento._log_levels),
        ("", "")
    )
end

function Base.log(handler::TestHandler, rec::Record)
    if String(rec[:level]) == handler.level && String(rec[:msg]) == handler.msg
        handler.found = (handler.level, handler.msg)
    end
end

end