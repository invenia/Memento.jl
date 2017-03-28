import Memento: Attribute

type TestRecord <: Record
    date::Attribute
    level::Attribute
    levelnum::Attribute
    name::Attribute
    msg::Attribute
end

@testset "Formatters" begin
    @testset "DefaultFormatter" begin
        rec = DefaultRecord(Dict{Symbol, Any}(
            :name => "Logger.example",
            :level => :info,
            :levelnum => 20,
            :msg => "blah",
        ))

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
        rec = TestRecord(
            Attribute(now()),
            Attribute("info"),
            Attribute(20),
            Attribute("root"),
            Attribute("blah"),
        )

        fmt = JsonFormatter()
        @test format(fmt, rec) == json(Dict(rec))
    end
end
