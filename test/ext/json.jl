using JSON

@testset "Ext - JSON" begin
    rec = DefaultRecord("Logger.example", "info", 20, "blah")

    fmt = DictFormatter(JSON.json)
    result = Memento.format(fmt, rec)
    @test isa(JSON.parse(result), Dict)

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

    fmt2 = DictFormatter(aliases, JSON.json)
    result = Memento.format(fmt2, rec)

    @test isa(JSON.parse(result), Dict)

    for key in [:location, :message, :timestamp, :process_id]
        @test contains(result, string(key))
        @test !contains(result, string(aliases[key]))
    end

    @test contains(result, "blah")
end