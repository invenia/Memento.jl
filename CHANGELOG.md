# Changelog

All notable changes to this project will be documented here.

## [1.5.0] - 2026-06-09

### Changes

- [#197](https://github.com/invenia/Memento.jl/pull/197): `Memento.TestUtils.@test_throws` no longer extends `Test.@test_throws`.
  - **Why:** [Julia 1.13](https://github.com/JuliaLang/julia/pull/60501) variadic `@test_throws(args...)` conflicts with Memento's 3-argument `@test_throws(logger, extype, expr)`.
  - **Impacts:** - tests that call the Memento 3-arg form of without qualifying. Only found [CloudWatchLogs.jl](https://github.com/invenia/CloudWatchLogs.jl/blob/5d6dcfbcba3466a2be0b29c6fbab3de76a0cfe56/test/mocked_aws.jl#L69), [Cliquing.jl](https://github.com/invenia/Cliquing.jl/blob/ae6a51ed757458e5e96972e440ef20ff7b90155e/test/runtests.jl#L126),  [ThreePhasePowerModels.jl](https://github.com/lanl-ansi/ThreePhasePowerModels.jl/blob/master/test/opendss.jl#L76) and [PowerModelsGMD.jl](https://github.com/lanl-ansi/PowerModelsGMD.jl/blob/master/test/parse.jl#L11) doing this. All, but one, are largely deprecated.
  - **Migration:** - qualify `@test_throws logger ExType expr` calls with `Memento.TestUtils.@test_throws logger ExType expr`, or add `import Memento.TestUtils: @test_throws`.
