#!/bin/bash

set -ev

if [[ "$TEST_TYPE" == "basic" ]]; then
    # Run parallel tests
    julia -e 'Pkg.test("Memento"; coverage=true)'
elif [[ "$TEST_TYPE" == "bench" ]]; then
    # Run benchmark tests
    export MEMENTO_BENCHMARK="true"
    export MEMENTO_CURR_COMMIT="HEAD"
    export MEMENTO_BASE_COMMIT="origin/master"
    julia -e 'Pkg.test("Memento"; coverage=true)'
elif [[ "$TEST_TYPE" == "userimage" ]]; then
    # Create a user image which includes Memento to make sure that _loggers is assigned at compile-time
    # See: https://github.com/invenia/Memento.jl/pull/21
    julia -e '
        LIB_PATH = abspath(Base.JULIA_HOME, Base.LIBDIR)
        sysimg_lib = joinpath(LIB_PATH, "julia", "sys.$(Libdl.dlext)")
        userimg_o = "userimg.o"
        userimg_lib = "userimg.$(Libdl.dlext)"
        run(`$(Base.julia_cmd()) --output-o $userimg_o --sysimage $sysimg_lib --startup-file=no -e "using Memento; logger = get_logger(\"Test\")"`)
        run(`cc -shared -o $userimg_lib $userimg_o -ljulia -L$LIB_PATH`)
    '
fi
