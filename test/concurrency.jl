# Currently, can't run io.jl and concurrency.jl at the same time as
# multiprocessing doesn't work with --compilecache=no
# needed for the mocking tests to working.

@testset "Concurrency" begin
    @testset "Async Logging" begin
        Memento.reset!()
        io = IOBuffer()

        try
            set_level(get_logger(), "info")
            add_handler(
                get_logger(),
                DefaultHandler(io, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            asyncmap(x -> warn(get_logger(), "message"), 1:10)
            all_msgs = split(takebuf_string(io), '\n')

            @test !isempty(all_msgs)
            @test all(m -> m == all_msgs[1], all_msgs[2:end-1])
        finally
            close(io)
        end
    end
    @testset "Parallel Logging" begin
        Memento.reset!()
        numprocs = addprocs(2)

        try
            # broadcast a filename to write to.
            @eval @everywhere parallel_test_filename = $(tempname())

            @everywhere using Memento
            @everywhere set_level(get_logger(), "info")
            @everywhere add_handler(
                get_logger(),
                DefaultHandler(parallel_test_filename, DefaultFormatter("{name} - {level}: {msg}")),
                "io"
            )

            pmap(x -> warn(get_logger(), "message"), 1:10)

            open(parallel_test_filename) do f
                all_msgs = readlines(f)
                @test !isempty(all_msgs)
                @test all(m -> m == all_msgs[1], all_msgs[2:end])
            end

            @test isfile(parallel_test_filename)
            @test is_windows() ? true : success(`rm $parallel_test_filename`)   # Get UNLINK Error on windows
        finally
            rmprocs(numprocs)
        end
    end
end
