# [Changing date format?](@id change_date_format)

The default date format is `yyyy-mm-dd HH:MM:SS`.
To change that, for example if you want to display milliseconds, you'll have to change the `Formatter` like so:

```julia
# Changes the formatter of the console handler of the root logger
gethandlers(getlogger())["console"].fmt = DefaultFormatter("[{date} | {name} | {level}]: {msg}"; date_fmt_string="yyyy-mm-dd HH:MM:SS.sss")
```
