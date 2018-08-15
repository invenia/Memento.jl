#!/bin/bash

set -ev

# Set up the build environment across Julia versions
# This portion is the same as the default Travis test script:
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/script/julia.rb
if [[ -a .git/shallow ]]; then
    git fetch --unshallow
fi
if [[ -f Project.toml || -f JuliaProject.toml ]]; then
    # Run build step
    julia --color=yes -e '
        if VERSION < v"0.7.0-DEV.5183"
            Pkg.clone(pwd())
            Pkg.build("Memento")
        else
            using Pkg
            Pkg.build()
        end
    '
    # Set up test step (run below)
    TESTCMD='
        if VERSION < v"0.7.0-DEV.5183"
            Pkg.test("Memento", coverage=true)
        else
            using Pkg
            Pkg.test(coverage=true)
        end
    '
else
    # Run build step
    julia --color=yes -e '
        VERSION >= v"0.7.0-DEV.5183" && using Pkg
        Pkg.clone(pwd())
        Pkg.build("Memento")
    '
    # Set up test step (run below)
    TESTCMD='
        VERSION >= v"0.7.0-DEV.5183" && using Pkg
        Pkg.test("Memento", coverage=true)
    '
fi

if [[ "$TEST_TYPE" == "basic" ]]; then
    # Run parallel tests
    julia --color=yes --check-bounds=yes -e "$TESTCMD"
elif [[ "$TEST_TYPE" == "bench" ]]; then
    # Run benchmark tests
    export MEMENTO_BENCHMARK="true"
    export MEMENTO_CURR_COMMIT="HEAD"
    export MEMENTO_BASE_COMMIT="origin/master"
    julia --color=yes --check-bounds=yes -e "$TESTCMD"
elif [[ "$TEST_TYPE" == "userimage" ]]; then
    # Create a user image which includes Memento to make sure that _loggers is assigned at compile-time
    # See: https://github.com/invenia/Memento.jl/pull/21
    julia --color=yes -e '
        VERSION >= v"0.7.0-DEV.3382" && using Libdl
        BINDIR = VERSION < v"0.7.0-DEV.3073" ? Base.JULIA_HOME : Sys.BINDIR
        LIB_PATH = abspath(BINDIR, Base.LIBDIR)
        sysimg_lib = joinpath(LIB_PATH, "julia", "sys.$(Libdl.dlext)")
        userimg_o = "userimg.o"
        userimg_lib = "userimg.$(Libdl.dlext)"
        run(`$(Base.julia_cmd()) --output-o $userimg_o --sysimage $sysimg_lib --startup-file=no -e "using Memento; logger = getlogger(\"Test\")"`)
        run(`cc -shared -o $userimg_lib $userimg_o -ljulia -L$LIB_PATH`)
    '
fi
