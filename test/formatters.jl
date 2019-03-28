@testset "Formatters" begin
    rec = DefaultRecord("Logger.example", "info", 20, "blah")

    # NOTE: This check might not be needed as of 0.6 because I can't find a
    # condition where the stacktrace is empty.
    no_lookup = DefaultRecord(
        Memento.Attribute(rec.date), Memento.Attribute(rec.level),
        Memento.Attribute(rec.levelnum), Memento.Attribute(rec.msg),
        Memento.Attribute(rec.name), Memento.Attribute(rec.pid),
        Memento.Attribute(nothing), Memento.Attribute(rec.stacktrace)
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

        @testset "Date handling" begin
            withenv("TZ" => "UTC+02") do
                local_date = ZonedDateTime(2012, 1, 1, 3, 1, 1, 123, localzone())
                local_datestr = "2012-01-01 03:01:01"
                utc_date = astimezone(local_date, tz"UTC")
                utc_datestr = Dates.format(utc_date, "yyyy-mm-dd HH:MM:SS")

                fmt = DefaultFormatter("{date}")
                tz_rec = SimpleRecord("info", "blah", local_date)
                @test Memento.format(fmt, tz_rec) == local_datestr

                utc_rec = SimpleRecord("info", "blah", utc_date)
                @test Memento.format(fmt, utc_rec) == local_datestr

                utc_fmt = DefaultFormatter("{date}", tz"UTC")
                @test Memento.format(utc_fmt, tz_rec) == utc_datestr
                @test Memento.format(utc_fmt, utc_rec) == utc_datestr

                date = DateTime(2012, 1, 1, 3, 1, 1)
                notz_rec = SimpleRecord("info", "blah", date)
                @test Memento.format(fmt, notz_rec) == local_datestr

                ts = 1531949014
                ts_rec = SimpleRecord("info", "blah", ts)
                @test Memento.format(fmt, ts_rec) == string(ts)
            end
        end
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
