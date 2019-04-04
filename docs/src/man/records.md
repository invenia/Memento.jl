# [Records](@id man_records)

Records store information about log events (e.g., message, timestamp, log level) that is used by [`Formatter`](@ref)s to format log messages.
A record behaves as a dictionary-like container with `Symbol` keys, and you can access the properties of a [`Record`](@ref) by using `getproperty` (i.e., `record.msg`).

By default, any subtypes of [`Record`](@ref) will treat its fields as keys.
Non-standard subtypes of [`Record`](@ref) should implement `getproperty(::MyRecord, ::Symbol)` and key-value pair iteration.

## AttributeRecords

An [`AttributeRecord`](@ref Memento.AttributeRecord) is an abstract subtype of [`Record`](@ref) that lazily evaluates its properties.
Fields are stored as [`Attribute`](@ref Memento.Attribute)s, which will evaluate a function and cache the result the first time it is read.

By default, any subtypes of [`AttributeRecord`](@ref Memento.AttributeRecord) will expect its fields to be [`Attribute`](@ref Memento.Attribute)s.
Non-standard subtypes of [`AttributeRecord`](@ref Memento.AttributeRecord) should implement `Base.getproperty(::MyRecord, ::Symbol)` and key-value pair iteration, where the values have been extracted from [`Attribute`](@ref Memento.Attribute)s using [`get`](@ref).

## Custom Record Types

While the [`DefaultRecord`](@ref) in Memento (a standard [`AttributeRecord`](@ref Memento.AttributeRecord)) provides many of the keys and values needed for most logging applications, you may need to implement your own [`Record`](@ref) type.
For example, if you're running a julia application on a cloud service provider like Amazon's EC2 you might want to include some general information about the resource your code is running on, which might result in a custom [`Record`](@ref) type that looks like:

```julia
# TODO: Fix this example.
mutable struct EC2Record <: AttributeRecord
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

    function EC2Record(name::AbstractString, level::AbstractString, levelnum::Int, msg)
        time = now()
        trace = Attribute{StackTrace}(get_trace)

        EC2Record(
            Attribute{DateTime}(() -> round(time, Dates.Second)),
            Attribute(level),
            Attribute(levelnum),
            Attribute{AbstractString}(msg),
            Attribute(name),
            Attribute(myid()),
            Attribute{StackFrame}(get_lookup(trace)),
            trace,
            Attribute(ENV["INSTANCE_ID"]),
            Attribute(ENV["PUBLIC_IP"]),
            Attribute(ENV["IAM_USER"]),
        )
    end
end
```

NOTE: The above example simply assumes that you have some relevant environment variables set on the machine, but you could also query Amazon for that information.
