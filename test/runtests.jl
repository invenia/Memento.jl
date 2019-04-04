using Test
using Distributed
using Sockets
using Suppressor
using JSON
using Syslogs
using Memento
using Memento.TestUtils
using TimeZones
using Dates
using Serialization

files = [
    "records.jl",
    "formatters.jl",
    "handlers.jl",
    "loggers.jl",
    "io.jl",
    "concurrency.jl",
    "test.jl",
    "stdlib.jl",
    "ext/json.jl",
]

Sys.isunix() ? push!(files, "ext/syslogs.jl") : nothing
haskey(ENV, "MEMENTO_BENCHMARK") ? files = ["benchmarks.jl"] : nothing

# for loggers.jl
struct TestError <: Exception
    msg
end

# for records.jl
struct SimpleRecord{T} <: Record
    level::String
    msg::String
    date::T
end

SimpleRecord(level, msg) = SimpleRecord(level, msg, Dates.now(tz"UTC"))

struct ConstRecord <: AttributeRecord
end

function Base.getproperty(::ConstRecord, attr::Symbol)
    if attr === :level
        return "error"
    elseif attr === :msg
        return "It's a ConstRecord"
    else
        throw(KeyError(attr))
    end
end

struct SimplestHandler <: Handler{Union{}, IOBuffer}
    buf::IOBuffer
end

struct FilterHandler <: Handler{Union{}, IOBuffer}
    buf::IOBuffer
    filters::Vector{Memento.Filter}
end

FilterHandler(buf::IOBuffer) = FilterHandler(buf, Memento.Filter[])
Base.push!(handler::FilterHandler, filter::Memento.Filter) = push!(handler.filters, filter)
Memento.getfilters(handler::FilterHandler) = handler.filters

function Memento.emit(handler::Union{SimplestHandler, FilterHandler}, record::Record)
    println(handler.buf, record.msg)
end

struct AsyncHandler <: Handler{Union{}, IOBuffer}
    buf::IOBuffer
    channel::Channel{Record}

    function AsyncHandler(buf::IOBuffer)
        channel = Channel{Record}(Inf)
        handler = new(buf, channel)

        task = @async process_record!(handler)
        bind(channel, task)

        return handler
    end
end

function process_record!(handler::AsyncHandler)
    while isopen(handler.channel)
        record = take!(handler.channel)
        println(handler.buf, record.msg)
    end
end

function Memento.emit(handler::AsyncHandler, record::Record)
    put!(handler.channel, record)
end

_props(cr::ConstRecord) = (:level => cr.level, :msg => cr.msg)

Base.iterate(cr::ConstRecord, state...) = iterate(_props(cr), state...)

@testset "Memento" begin

@testset "Logging" begin
    @testset "Sample Usage" begin
        Memento.config!("info"; fmt="[{date} | {level} | {name}]: {msg}", colorized=false)
        logger1 = getlogger(@__MODULE__)
        debug(logger1, "Something that won't get logged.")
        Memento.info(logger1, "Something you might want to know.")
        Memento.warn(logger1, "This might cause an error.")
        Memento.warn(logger1, ErrorException("A caught exception that we want to log as a warning."))
        @test_throws ErrorException error(logger1, "Something that should throw an error.")
        @test_throws ErrorException error(logger1, ErrorException("A caught exception that we should log and rethrow"))
        logger2 = getlogger("Pkg.Foo.Bar")
    end

    @testset "Logger Hierarchy" begin
        Memento.reset!()
        foo = getlogger("Foo")
        bar = getlogger("Foo.Bar")
        baz = getlogger("Foo.Bar.Baz")
        car = getlogger("Foo.Car")

        for l in (foo, bar, baz, car)
            @test isset(l)
            @test getlevel(l) == "info"
            @test length(gethandlers(l)) == 0
        end

        root_io = IOBuffer()
        baz_io = IOBuffer()

        push!(getlogger(), DefaultHandler(root_io, DefaultFormatter("{name} - {level}: {msg}")))

        msg = "This should propagate and log because all loggers are set to :warn by default."
        expected = "Foo.Car - warn: $msg"
        Memento.warn(car, msg)
        result = String(take!(root_io))
        @test occursin(expected, result)

        msg = "This should not log because debug messages don't have high enough importance."
        debug(bar, msg)
        result = String(take!(root_io))
        @test result == ""

        setlevel!(getlogger(), "debug")
        msg = "This should log to because we've set the root logger to info"
        debug(getlogger(), msg)
        result = String(take!(root_io))
        expected = "root - debug: $msg"
        @test occursin(expected, result)

        msg = "This should not log because `bar` is set too low"
        debug(bar, msg)
        result = String(take!(root_io))
        @test result == ""

        setlevel!(bar, "debug")
        msg = "This should still not log because `foo` is set too low"
        debug(bar, msg)
        result = String(take!(root_io))
        @test result == ""

        # Now if we have the chain of root, foo and bar all set to info then the log record
        # will propagate up from the bar logger to be written to the buffer by the root loggers handler.
        setlevel!(foo, "debug")
        msg = "Now this should log because `bar`, `foo` and the root logger are all set appropriately."
        debug(bar, msg)
        expected = "Foo.Bar - debug: $msg"
        result = String(take!(root_io))
        @test occursin(expected, result)

        # Now we'll test that a child logger can log messages to its handler even if it doesn't
        # propagate to the root logger.
        setlevel!(baz, "debug")
        push!(baz, DefaultHandler(baz_io, DefaultFormatter("{name} - {level}: {msg}")))

        # Reset the parent loggers
        setlevel!.((foo, bar), "info")

        msg = "This should log to `baz_io`, but not `root_io`"
        debug(baz, msg)
        expected = "Foo.Bar.Baz - debug: $msg"
        result = String(take!(baz_io))
        @test occursin(expected, result)

        result = String(take!(root_io))
        @test result == ""

        msg = "This should be logged to both `root_io` and `baz_io`"
        Memento.info(baz, msg)
        expected = "Foo.Bar.Baz - info: $msg"
        result = String(take!(baz_io))
        @test occursin(expected, result)

        result = String(take!(root_io))
        @test occursin(expected, result)
    end

    @testset "Default Levels" begin
        @test allunique(values(Memento._log_levels))
    end
end


# Test files should assume the const _loggers has been reset
for file in files
    Memento.reset!()
    include(file)
end

end
