# Conclusion

We've reviewed all the different components you can use to configure logging in you application, but how do they all fit together?
Let's work through a sample use case that uses all of the components we've discussed.

NOTE: The example provided is a bit contrived for simplicity.

First, let's start with a julia Pkg called `Wrapper` that runs a function wrapped in some Memento logging.

```julia
# Wrapper.jl
module Wrapper

using Memento

function run(f::Function, args...; kwargs...)
    ret = nothing
    logger = getlogger(current_module())
    info(logger, "Got logger $logger")

    notice(logger, "Running function...")

    try
        ret = f(args...; kwargs...)
    catch exc
        warn(logger, exc)
    end

    return ret
end

end
```

Now we want to start writing our application code that uses this package, but our logging requirements are very specific and Memento doesn't support our particular use case yet.

Requirements:

1. This will be run on Amazon EC2 instances and we want our log message to contain information about the machine the code is being run on.
2. We want our logs to be written to an HTTP REST service (kinda like Loggly), where the endpoint is of the form `https://<account_uri>/<app_name>/<level>?AccessKey=<access_key>`.
3. We want our logs to be written in a CSV format... for some reason.

Okay, so how do we address all of those requirements using Memento's API?

Steps:

1. Create a custom [`Record`](@ref) type called `EC2Record` that stores the Amazon EC2 information to address the first requirement.
2. Create a custom `IO` type called `REST` that writes log strings to the REST endpoint to partly address the second requirement.
3. Create a custom [`Formatter`](@ref) type called `CSVFormatter` that converts `Record`s to (comma, tab, etc) delimited strings.

NOTE: The code below is not intended to be a working example because it assumes a fake REST service.

```julia
# myapp.jl
using Wrapper
using Memento
using Requests  # For send logs to our fake logging REST service

# Start by setting up our basic console logging for the root logger.
logger = Memento.config!("info"; fmt="[{level} | {name}]: {msg}")

# We create our custom EC2Record type
mutable struct EC2Record <: Record
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

    function EC2Record(args::Dict)
        time = now()
        trace = Attribute{StackTrace}(get_trace)

        EC2Record(
            Attribute{DateTime}(() -> round(time, Dates.Second)),
            Attribute(args[:level]),
            Attribute(args[:levelnum]),
            Attribute{AbstractString}(get_msg(args[:msg])),
            Attribute(args[:name]),
            Attribute(myid()),
            Attribute{StackFrame}(get_lookup(trace)),
            trace,
            Attribute(ENV["INSTANCE_ID"]),
            Attribute(ENV["PUBLIC_IP"]),
            Attribute(ENV["IAM_USER"]),
        )
    end
end

# A really simple CSVFormatter
mutable struct CSVFormatter <: Formatter
    delim::Char
    vals::Array{Symbol}

    CSVFormatter(delim=',', vals=Array{Symbol}()) = new(delim, vals)
end

function format(fmt::CSVFormatter, rec::Record)
    fields = isempty(fmt.vals) ? keys(rec) : fmt.vals

    # For a real world use case we might want to do some
    # string formatting of fields like :stacktrace here.

    val = map(k -> rec[k], fields)

    return join(val, fmt.delim)
end

# Create our custom REST IO type
mutable struct REST <: IO
    account_uri::AbstractString
    app_name::AbstractString
    access_key::AbstractString
end

# Our print method builds the correct uri using the log level
# and sends the put request.
function println(io::REST, level::AbstractString, msg::AbstractString)
    uri = "https://$(io.account_uri)/$(io.app_name)/$level?AccessKey=$(io.access_key)"
    @async put(uri; data=msg)
end

# Not relevant, but good to have.
flush(io::REST) = io

# We still need to special case the `DefaultHandler` `log` method to call  `println(io::REST, level, msg)`
function log(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:REST}
    msg = format(handler.fmt, rec)
    println(handler.io, rec.level, msg)
    flush(handler.io)
end

# Now we can tie this all together, but adding a new DefaultHandler
# with the CSVFormatter and REST IO type.
push!(
    logger,
    DefaultHandler(
        REST(
            "memento.mylogrestservice.com", "myapp",
            "qM033cSYWTuu8VpXFSZm9QMm9ZESOU2A"
        ),
        CSVFormatter(
            ',',
            [:date, :name, :level, :msg, :iam_user, :public_ip, :instance_id]
        )
    )
)

# Don't forget to update the root logger `Record` type.
setrecord!(logger, EC2Record)

Wrapper.run(exp, 10)
# Should log some things.

Wrapper.run(exp, "foo")
# Should log a warning about a method error.
```
