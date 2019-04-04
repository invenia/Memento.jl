@testset "Records" begin
    @testset "Record" begin
        @testset "SimpleRecord (test)" begin
            rec = SimpleRecord("info", "blah")

            @test rec.level == "info"
            @test rec.msg == "blah"

            dict = Dict(rec)
            @test rec.msg == dict[:msg]
        end
    end

    @testset "AttributeRecord" begin
        @testset "ConstRecord (test)" begin
            rec = ConstRecord()

            @test rec.level == "error"
            @test rec.msg == "It's a ConstRecord"

            dict = Dict(rec)
            @test rec.msg == dict[:msg]
        end

        @testset "DefaultRecord" begin
            rec = DefaultRecord("Logger.example", "info", 20, "blah")

            @test haskey(rec, :date)
            @test rec.date == something(rec.date)

            dict = Dict(rec)
            @test rec.date == dict[:date]
        end
    end
end
