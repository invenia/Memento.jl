import Memento: Attribute

@testset "Formatters" begin
    rec = DefaultRecord(Dict{Symbol, Any}(
        :name => "Logger.example",
        :level => :info,
        :levelnum => 20,
        :msg => "blah",
    ))
    @testset "DefaultFormatter" begin
        fmt = DefaultFormatter("{lookup}|{msg}|{stacktrace}")
        result = format(fmt, rec)
        parts = split(result, "|")
        @test length(parts) == 3
        @test parts[2] == "blah"
        @test length(parts[1]) > 0
        @test length(parts[3]) > 0
        @test contains(parts[3], "formatters")
        @test !contains(parts[3], "get_trace")
        @test !contains(parts[3], "DefaultRecord")
        @test !contains(parts[3], "get")
    end

    @testset "JsonFormatter" begin
        fmt = JsonFormatter()
        result = format(fmt, rec)
        for key in [:date, :name, :level, :lookup, :stacktrace, :msg]
            @test contains(result, string(key))
        end

        @test contains(result, "blah")

        aliases = Dict(
            :logger => :name,
            :level => :level,
            :timestamp => :date,
            :location => :lookup,
            :message => :msg,
            :process_id => :pid,
        )

        fmt2 = JsonFormatter(aliases)
        result = format(fmt2, rec)

        for key in [:location, :message, :timestamp, :process_id]
            @test contains(result, string(key))
            @test !contains(result, string(aliases[key]))
        end

        @test contains(result, "blah")
    end
end
