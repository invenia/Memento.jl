@testset "Records" begin
    @testset "DefaultRecord" begin
        rec = DefaultRecord("Logger.example", "info", "blah")

        @test rec[:date] == get(rec.date)
        @test get(rec.date) == get(rec.date.x)

        dict = Dict(rec)
        @test rec[:date] == dict[:date]
    end
end
