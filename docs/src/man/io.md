# IO

Memento writes all logs to any subtype of `IO` including `IOBuffer`s, `LibuvStream`s, `Pipe`s, `File`s, etc. Memento also comes with 2 logging specific `IO` types.

1. `FileRoller` - Does automatic log file rotation.
2. `Syslog` - Write to syslog using the `logger` command. Please note that syslog output is only available on systems that have `logger` utility installed. (This should include both Linux and OS X, but typically excludes Windows.) Note that BSD's `logger` (used on OS X) will append a second process ID, which is the PID of the `logger` tool itself.

To create your own `IO` types you need to subtype `IO` and implement the `println` and `flush` methods.
