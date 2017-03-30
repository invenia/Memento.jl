# A utility script for running a comparison benchmark.

using PkgBenchmark

import BenchmarkTools:
    BenchmarkGroup,
    TrialJudgement,
    prettydiff,
    memory,
    ratio,
    isregression

function flatten(group::BenchmarkGroup; prefix="")
    results = Pair[]

    for (name, val) in group.data
        if isa(val, BenchmarkGroup)
            append!(results, flatten(val; prefix="$prefix/$name"))
        elseif isa(val, TrialJudgement)
            push!(results, "$prefix/$name" => val)
        end
    end

    return results
end

@testset "Benchmarks" begin
    curr_commit = get(ENV, "MEMENTO_CURR_COMMIT", "16b620c")
    base_commit = get(ENV, "MEMENTO_BASE_COMMIT", "be07e98")
    result = judge(
        "Memento",
        curr_commit,
        base_commit;
        saveresults=false,
        promptsave=false,
        f=median,
        judgekwargs=Dict(
            :time_tolerance => 0.2,
            :memory_tolerance => 0.2,
        ),
    )

    flat_result = flatten(result["Memento"])

    println("Benchmark, Time, Memory")
    for element in flat_result
        println(string(
            element.first,
            ", ",
            prettydiff(time(ratio(element.second))),
            " ( ",
            time(element.second),
            " )",
            ", ",
            prettydiff(memory(ratio(element.second))),
            " ( ",
            memory(element.second),
            " )",
        ))
    end

    for element in flat_result
        @test !isregression(element.second)
    end
end
