#!/bin/bash

set -ev

if [[ "$TEST_TYPE" == "parallel" ]]; then
    # Run parallel tests
    julia -e 'Pkg.test("Memento"; coverage=true)'
elif [[ "$TEST_TYPE" == "io" ]]; then
    # Run io tests (with mocking) and coverage
    julia --compilecache=no -e 'Pkg.test("Memento"; coverage=true)'
elif [[ "$TEST_TYPE" == "bench" ]]; then
    # Run benchmark tests
    export MEMENTO_BENCHMARK="true"
    export MEMENTO_CURR_COMMIT="HEAD"
    export MEMENTO_BASE_COMMIT="origin/master"
    julia -e 'Pkg.test("Memento"; coverage=true)'
elif [[ "$TEST_TYPE" == "userimage" ]]; then
    julia -e '
        LIB_PATH = abspath(Base.JULIA_HOME, Base.LIBDIR)
        sysimg_lib = joinpath(LIB_PATH, "julia", "sys.$(Libdl.dlext)")
        userimg_o = "userimg.o"
        userimg_lib = "userimg.$(Libdl.dlext)"
        run(`$(Base.julia_cmd()) --output-o $userimg_o --sysimage $sysimg_lib --startup-file=no -e "using Memento; logger = get_logger(\"Test\")"`)
        run(`cc -shared -o $userimg_lib $userimg_o -ljulia -L$LIB_PATH`)
    '
fi
