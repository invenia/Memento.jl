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
