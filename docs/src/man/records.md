# Records

`Record`s describe a set of log `Attributes` that should be available to a `Formatter` on every log message.

NOTE: The `Attribute` type is used as a way to provide lazy evaluation of log record elements.

While the `DefaultRecord` in Memento provides many of the keys and values needed for most logging applications, you may need to implement your own `Record` type.
For example, if you're running a julia application on a cloud service provider like Amazon's EC2 you might want to include some general information about the resource your code is running on, which might result in a custom `Record` type that looks like:

```julia
# TODO: Fix this example.
type EC2Record <: Record
    date::Attribute
    level::Attribute
    levelnum::Attribute
    msg::Attribute
    name::Attribute
    pid::Attribute
    lookup::Attribute
    stacktrace::Attribute
    instance_id::Attribute
    public_ip::Attribute
    iam_user::Attribute

    function EC2Record(name::AbstractString, level::AbstractString, msg)
        time = now()
        trace = Attribute(StackTrace, get_trace)

        EC2Record(
            Attribute(DateTime, () -> round(time, Base.Dates.Second)),
            Attribute(level),
            Attribute(-1),
            Attribute(AbstractString, get_msg(msg)),
            Attribute(name),
            Attribute(myid()),
            Attribute(StackFrame, get_lookup(trace)),
            trace,
            Attribute(ENV["INSTANCE_ID"]),
            Attribute(ENV["PUBLIC_IP"]),
            Attribute(ENV["IAM_USER"]),
        )
    end
end
```
NOTE: The above example simply assumes that you have some relevant environment variables set on
the machine, but you could also query Amazon for that information.
