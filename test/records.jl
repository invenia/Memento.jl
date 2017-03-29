@testset "Records" begin
    @testset "DefaultRecord" begin
        rec = DefaultRecord(Dict{Symbol, Any}(
            :name => "Logger.example",
            :level => :info,
            :levelnum => 20,
            :msg => "blah",
        ))

        @test rec[:date] == get(rec, :date)
        @test rec[:date] == get(rec.date)
        @test get(rec.date) == get(rec.date.x)

        dict = Dict(rec)
        @test rec[:date] == dict[:date]
    end
end
