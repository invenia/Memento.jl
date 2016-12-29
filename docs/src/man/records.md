# Records

`Record`s describe a set of key value pairs that should be available to a  `Formatter` on every log message.

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

While the `DefaultRecord` in Memento provides many of the keys and values needed for most logging applications, you may need to implement your own `Record` type.
For example, if you're running a julia application on a cloud service provider like Amazon's EC2 you might want to include some general information about the resource your code is running on, which might result in a custom `Record` type that looks like:

```julia
type EC2Record <: Record
    dict::Dict{Symbol, Any}

    function EC2Record(args::Dict)
        trace = StackTraces.remove_frames!(
            StackTraces.stacktrace(),
            [:DefaultRecord, :log, Symbol("#log#22"), :info, :warn, :debug]
        )

        new(Dict(
            :date => round(now(), Base.Dates.Second),
            :level => args[:level],
            :levelnum => args[:levelnum],
            :msg => args[:msg],
            :name => args[:name],
            :pid => myid(),
            :lookup => isempty(trace) ? nothing : first(trace),
            :stacktrace => trace,
            :instance_id => ENV["INSTANCE_ID"],
            :public_ip => ENV["PUBLIC_IP"],
            :iam_user => ENV["IAM_USER"],
            ...
        ))
    end
end
```
NOTE: The above example simply assumes that you have some relevant environment variables set on
the machine, but you could also query Amazon for that information.
