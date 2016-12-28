# Records

`Record`s describe a set of key value pairs that should be available to a  `Formatter` on every log message. While the `DefaultRecord` in Memento provides many of the keys and values need for most logging applications, you may need to implement your own `Record` type.

Internal `DefaultRecord` Dict:
```julia
Dict(
    :date => round(now(), Base.Dates.Second),
    :level => args[:level],
    :levelnum => args[:levelnum],
    :msg => args[:msg],
    :name => args[:name],
    :pid => myid(),
    :lookup => isempty(trace) ? nothing : first(trace),
    :stacktrace => trace,
)
```
