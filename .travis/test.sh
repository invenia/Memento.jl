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
    julia -e 'Pkg.test("Memento"; coverage)'
fi
