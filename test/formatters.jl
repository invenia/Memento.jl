@testset "Formatters" begin
    rec = DefaultRecord("Logger.example", "info", 20, "blah")

    # NOTE: This check might not be needed as of 0.6 because I can't find a
    # condition where the stacktrace is empty.
    no_lookup = DefaultRecord(
        rec.date, rec.level, rec.levelnum, rec.msg, rec.name, rec.pid,
        Memento.Attribute(nothing), rec.stacktrace
    )

    @testset "DefaultFormatter" begin
        fmt = DefaultFormatter("{lookup}|{msg}|{stacktrace}")
        result = Memento.format(fmt, rec)
        parts = split(result, "|")
        @test length(parts) == 3
        @test parts[2] == "blah"
        @test length(parts[1]) > 0
        @test length(parts[3]) > 0
        @test occursin("formatters", parts[3])
        @test !occursin("get_trace", parts[3])
        @test !occursin("DefaultRecord", parts[3])
        @test !occursin("get", parts[3])

        nl_result = Memento.format(fmt, no_lookup)
        @test startswith(nl_result, "<nothing>")
    end

    @testset "DictFormatter" begin
        fmt = DictFormatter()
        result = Memento.format(fmt, rec)
        for key in [:date, :name, :level, :lookup, :stacktrace, :msg]
            @test occursin(string(key), result)
        end

        @test occursin("blah", result)

        aliases = Dict(
            :logger => :name,
            :level => :level,
            :timestamp => :date,
            :location => :lookup,
            :message => :msg,
            :process_id => :pid,
        )

        fmt2 = DictFormatter(aliases)
        result = Memento.format(fmt2, rec)

        for key in [:location, :message, :timestamp, :process_id]
            @test occursin(string(key), result)
            @test !occursin(string(aliases[key]), result)
        end

        @test occursin("blah", result)

        nl_result = Memento.format(fmt, no_lookup)
        @test occursin("<nothing>", nl_result)
    end
end
