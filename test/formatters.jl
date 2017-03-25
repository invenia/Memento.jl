import Memento: Attribute

type TestRecord <: Record
    dict::Dict{Symbol, Attribute}
end

@testset "Formatters" begin
    @testset "DefaultFormatter" begin

    end

    @testset "JsonFormatter" begin
        rec = TestRecord(
            Dict{Symbol, Attribute}(
                :date => Attribute(now()),
                :level => Attribute("info"),
                :levelnum => Attribute(20),
                :name => Attribute("root"),
                :msg => Attribute("blah"),
            )
        )

        fmt = JsonFormatter()
        @test format(fmt, rec) == json(Dict(rec))
        ret = format(fmt, DefaultRecord(Dict(rec)))

        @test contains(ret, "lookup")
        @test contains(ret, "stacktrace")
    end
end
