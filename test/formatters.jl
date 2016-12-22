type TestRecord <: Record
    dict::Dict{Symbol, Any}
end

@testset "Formatters" begin
    @testset "DefaultFormatter" begin

    end

    @testset "JsonFormatter" begin
        rec = TestRecord(
            Dict{Symbol, Any}(
                :date => now(),
                :level => "info",
                :levelnum => 20,
                :name => "root",
                :msg => "blah"
            )
        )

        fmt = JsonFormatter()
        @test format(fmt, rec) == json(rec.dict)
        ret = format(fmt, DefaultRecord(rec.dict))

        @test contains(ret, "lookup")
        @test contains(ret, "stacktrace")
    end
end
