# [IO](@id man_io)

Memento writes all logs to any subtype of `IO` including `IOBuffer`s, `LibuvStream`s, `Pipe`s, `File`s, etc.
Memento also comes with a logging-specific `IO` type, [`FileRoller`](@ref), which does automatic log file rotation.

The [Syslogs](https://github.com/invenia/Syslogs.jl) package provides the `Syslog` `IO` type to write to syslog using the `logger` command. Please note that syslog output is only available on systems that have `logger` utility installed (this should include both Linux and macOS, but typically excludes Windows). Note that BSD's `logger` (used on macOS) will append a second process ID, which is the PID of the `logger` tool itself.

To create your own `IO` types for use with Memento you need to subtype `IO` and implement the `println` and `flush` methods.
