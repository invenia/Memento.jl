# Another logging library?

*...or why did you fork [Lumberjack.jl](https://github.com/WestleyArgentum/Lumberjack.jl)?*

The short answer is that none of the existing logging libraries quite fit our requirements.
The summary table provided below shows that all of the existing libraries are missing more than 1 requirement.
Our initial goal was to add more tests, hierarchical logging and some API changes to Lumberjack as it seemed to have the best balance of features and test coverage.
In the end, our changes diverged enough from Lumberjack that it made more sense to fork the project.


Properties | [Logging.jl](https://github.com/kmsquire/Logging.jl) | [Lumberjack.jl](https://github.com/WestleyArgentum/Lumberjack.jl) | [MiniLogging.jl](https://github.com/colinfang/MiniLogging.jl) | [Memento.jl](https://github.com/invenia/Memento.jl)
--- | --- | --- | --- | ---
Versions | 0.3.1 | 2.1.0 | 0.0.2 | N/A
Coverage | 61% | 76% | 87% | 100%
Unix | Yes | Yes | Yes | Yes
Windows | Yes | No | No | Yes
Julia | 0.4, 0.5 | 0.4, 0.5 | 0.5 | 0.5
Hierarchical | [Kinda](https://github.com/colinfang/MiniLogging.jl#why-another-logging-package) | No | Yes | Yes
Custom Formatting | No | [Kinda](https://github.com/WestleyArgentum/Lumberjack.jl#timbertruck) | No | Yes
Custom IO Types | Yes | Yes | Yes | Yes
Syslog | Yes | Yes | No | Yes
Color | Yes | Yes | No | Yes

You can see from the table that Memento covers all of our logging requirements and has significantly higher test coverage.
