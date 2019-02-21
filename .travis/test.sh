#!/bin/bash

set -ev

# Set up the build environment across Julia versions
# This portion is the same as the default Travis test script:
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/julia.rb
if [[ -a .git/shallow ]]; then
    git fetch --unshallow
fi
# Run build step
julia --color=yes --project=. -e 'using Pkg; Pkg.build()'
# Set up test step (run below)
TESTCMD='using Pkg; Pkg.test(coverage=true)'

if [[ "$TEST_TYPE" == "basic" ]]; then
    # Run parallel tests
    julia --color=yes --check-bounds=yes --project=. -e "$TESTCMD"
elif [[ "$TEST_TYPE" == "bench" ]]; then
    # Run benchmark tests
    export MEMENTO_BENCHMARK="true"
    export MEMENTO_CURR_COMMIT="HEAD"
    export MEMENTO_BASE_COMMIT="origin/master"
    julia --color=yes --check-bounds=yes --project=. -e "$TESTCMD"
elif [[ "$TEST_TYPE" == "userimage" ]]; then
    # Create a user image which includes Memento to make sure that _loggers is assigned at compile-time
    # See: https://github.com/invenia/Memento.jl/pull/21
    julia --color=yes --project=. -e '
        using Libdl
        LIB_PATH = abspath(Sys.BINDIR, Base.LIBDIR)
        sysimg_lib = joinpath(LIB_PATH, "julia", "sys.$(Libdl.dlext)")
        userimg_o = "userimg.o"
        userimg_lib = "userimg.$(Libdl.dlext)"
        code = "Base.reinit_stdio(); using Memento; using Test; logger = getlogger(\"Test\")"
        run(`$(Base.julia_cmd()) --output-o $userimg_o --sysimage $sysimg_lib --startup-file=no -e "$code"`)
        run(`cc -shared -o $userimg_lib $userimg_o -ljulia -L$LIB_PATH`)
    '
fi
