var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Memento.jl-1",
    "page": "Home",
    "title": "Memento.jl",
    "category": "section",
    "text": "(Image: Build Status) (Image: Build status) (Image: codecov)Memento is flexible hierarchical logging library for julia."
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "julia> Pkg.add(\"Memento\")"
},

{
    "location": "index.html#Quick-Start-1",
    "page": "Home",
    "title": "Quick Start",
    "category": "section",
    "text": "Start by using Mementojulia> using MementoNow setup basic logging on the root logger with Memento.config.julia> logger = Memento.config(\"debug\"; fmt=\"[{level} | {name}]: {msg}\")\nLogger(root)Now start logging with the root logger.julia> debug(logger, \"Something to help you track down a bug.\")\n[debug | root]: Something to help you track down a bug.\n\njulia> info(logger, \"Something you might want to know.\")\n[info | root]: Something you might want to know.\n\njulia> notice(logger, \"This is probably pretty important.\")\n[notice | root]: This is probably pretty important.\n\njulia> warn(logger, \"This might cause an error.\")\n[warn | root]: This might cause an error.\n\njulia> warn(logger, ErrorException(\"A caught exception that we want to log as a warning.\"))\n[warn | root]: A caught exception that we want to log as a warning.\n\njulia> error(logger, \"Something that should throw an error.\")\n[error | root]: Something that should throw an error.\nERROR: Something that should throw an error.\n in error(::Memento.Logger, ::String) at /Users/rory/.julia/v0.5/Memento/src/loggers.jl:250Now maybe you want to have a different logger for each module/submodule. This allows you to have custom logging behaviour and handlers for different modules and provides easier to parse logging output.julia> child_logger = getlogger(\"Foo.bar\")\nLogger(Foo.bar)\n\njulia> setlevel!(child_logger, \"warn\")\n\"warn\"\n\njulia> push!(child_logger, DefaultHandler(tempname(), DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\")))\n\nMemento.DefaultHandler{Memento.DefaultFormatter,IOStream}(Memento.DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\"),IOStream(<file /var/folders/_6/25myjdtx2fxgjvznn19rp22m0000gn/T/julia8lonyA>),Dict{Symbol,Any}(Pair{Symbol,Any}(:is_colorized,false)))\n\njulia> debug(child_logger, \"Something that should only be printed to STDOUT on the root_logger.\")\n[debug | Foo.bar]: Something that should only be printed to STDOUT on the root_logger.\n\njulia> warn(child_logger, \"Warning to STDOUT and the log file.\")\n[warn | Foo.bar]: Warning to STDOUT and the log file.NOTE: We used getlogger(\"Foo.bar\"), but you can also do getlogger(current_module()) which allows us to avoid hard coding in logger names."
},

{
    "location": "man/intro.html#",
    "page": "Introduction",
    "title": "Introduction",
    "category": "page",
    "text": ""
},

{
    "location": "man/intro.html#Introduction-1",
    "page": "Introduction",
    "title": "Introduction",
    "category": "section",
    "text": ""
},

{
    "location": "man/intro.html#Logging-levels-1",
    "page": "Introduction",
    "title": "Logging levels",
    "category": "section",
    "text": "You can globally set the minimum logging level with Memento.config.julia>Memento.config(\"debug\")Will log all messages for all loggers at or above \"debug\".julia>Memento.config(\"warn\")Will only log message at or above the \"warn\" level.We can also set the logging level for specific loggers or collections of loggers if we explicitly set the level on an existing logger.julia>setlevel!(getlogger(\"Main\"), \"info\")Will only set the logging level to \"info\" for the \"Main\" logger and any future children of the \"Main\" logger.By default Memento has 9 logging levels.Level Number Description\nnot_set 0 Will not log anything, but may still propagate messages to its parents.\ndebug 10 Log verbose message used for debugging.\ninfo 20 Log general information about a program.\nnotice 30 Log important events that are still part of normal execution.\nwarn 40 Log warning that may cause the program to fail.\nerror 50 Log errors and throw or rethrow an error.\ncritical 60 Entire application has crashed.\nalert 70 The entire application crashed and is not recoverable. Probably need to wake up the sysadmin.\nemergency 80 System is unusable. Applications shouldn\'t need to call this so it may be removed in the future."
},

{
    "location": "man/intro.html#Formatting-logs-1",
    "page": "Introduction",
    "title": "Formatting logs",
    "category": "section",
    "text": "Unless explicitly changed Memento will use a DefaultFormatter for handlers. This Formatter takes a format string for mapping log record fields into each log message. Desired fields are wrapped in curly brackets (ie: \"{msg}\")The default format string is \"[{level} | {name}]: {msg}\", which produces messages that look like[info | root]: my info message.\n[warn | root]: my warning message.\n...However, you could change this string to just \"{level}: {msg}\", which would produce messages that look likeinfo: my info message.\nwarn: my warning message.\n...The simplest way to globally change the log format is with Memento.configjulia> Memento.config(\"debug\"; fmt=\"[{level} | {name}]: {msg}\")The following fields are available via the DefaultRecord.Field Description\ndate The log event date rounded to seconds\nlevel The log event level as a string\nlevelnum The integer value for the log event level\nmsg The source log event message\nname The name of the source logger\npid The pid where the log event occured\nlookup The top StackFrame of the stacktrace for the log event\nstacktrace A StackTrace for the log eventFor more details on the DefaultFormatter and DefaultRecord please see the API docs. More general information on Formatters and Records will be discussed later in this manual."
},

{
    "location": "man/intro.html#Architecture-1",
    "page": "Introduction",
    "title": "Architecture",
    "category": "section",
    "text": "There are five main components of Memento.jl that you can manipulate:Loggers\nHandlers\nFormatters\nRecords\nIOThe remainder of this manual will discuss how you can use these components to customize Memento to you particular application."
},

{
    "location": "man/loggers.html#",
    "page": "Loggers",
    "title": "Loggers",
    "category": "page",
    "text": ""
},

{
    "location": "man/loggers.html#Loggers-1",
    "page": "Loggers",
    "title": "Loggers",
    "category": "section",
    "text": "A Logger is the primary component you use to send formatted log messages to various IO outputs. This type holds information needed to manage the process of creating and storing logs. There is a default \"root\" logger stored in global _loggers inside the Memento module. Since Memento implements hierarchical logging you should define child loggers that can be configured independently and better describe the individual components within your code. To create a new logger for you code it is recommended to do getlogger(current_module()).julia> logger = getlogger(current_module())Log messages are brought to different output streams by Handlers. From here you can add and remove handlers. To add a handler that writes to rotating log files, simply:julia> push!(logger, DefaultHandler(\"mylogfile.log\"))Now there is a handler named \"file-logging\", and it will write all of your logs to mylogfile.log. Your logs will still show up in the console, however, because -by default- there is a handler named \"console\" already hard at work.The operations presented here will only apply to the current logger, leaving existing loggers (e.g., Logger(root)) unaffected. However, any child loggers of Logger(Main) (e.g., Logger(Main.Foo) will have both the \"console\" and \"file-logging\" handlers available to it.We can also set the level and Record type for our logger.julia> setlevel!(logger, \"warn\")Now we won\'t log any messages with this logger unless they are at least warning messages.julia> setrecord!(logger, MyRecord)Now our logger will call create MyRecords instead of DefaultRecords"
},

{
    "location": "man/handlers.html#",
    "page": "Handlers",
    "title": "Handlers",
    "category": "page",
    "text": ""
},

{
    "location": "man/handlers.html#Handlers-1",
    "page": "Handlers",
    "title": "Handlers",
    "category": "section",
    "text": "As we\'ve already seen, Handlers can be used to write log messages to different IO types. More specifically, handlers are parameterized types that describe the relationship of how Formatter and IO types are used to take a Record (a kind of specified Dict) -> convert it to a String with the Formatter and write that to an IO type.In the simplest case a Handler definition would like:mutable struct MyHandler{F<:Formatter, O<:IO} <: Handler{F, O}\n    fmt::F\n    io::O\nend\n\nfunction emit(handler::MyHandler{F, O}, rec::Record) where {F<:Formatter, O<:IO}\n    str = Memento.format(handler.fmt, rec)\n    println(handler.io, str)\n    flush(handler.io)\nendHowever, under some circumstances it may be necessary to customize this behaviour based on the Formatter, IO or Record types being used. For example, if you\'d like to use the Syslog IO type from Syslogs.jl you\'ll need topass in an extra level argument to its println so we special case this like so:using Syslogs\n\nfunction emit(handler::MyHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}\n    str = Memento.format(handler.fmt, rec)\n    println(handler.io, rec[:level], str)\n    flush(handler.io)\nend"
},

{
    "location": "man/formatters.html#",
    "page": "Formatters",
    "title": "Formatters",
    "category": "page",
    "text": ""
},

{
    "location": "man/formatters.html#Formatters-1",
    "page": "Formatters",
    "title": "Formatters",
    "category": "section",
    "text": "Formatters describe how to take a Record and convert it into properly formatted string. Currently, there are two types of Formatters.DefaultFormatter: use a simple template string format to map keys in the Record to places in the resulting string. (ie: DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\")\nDictFormatter: builds an appropriately formatted Dict from the Record so that it can be serialized to a string with various formats. (e.g., string, JSON.json).You should only need to write a custom Formatter type if you\'re needing to produce very specific string formats regardless of the Record type being used. For example, we may want a CSVFormatter which always writes logs in a CSV Format.If you just need to customize the behaviour of an existing Formatter to a specific Record type then you should simply overload the format method for that Formatter.Example)function Memento.format(fmt::DefaultFormatter, rec::MyRecord)\n    ...\nend"
},

{
    "location": "man/records.html#",
    "page": "Records",
    "title": "Records",
    "category": "page",
    "text": ""
},

{
    "location": "man/records.html#Records-1",
    "page": "Records",
    "title": "Records",
    "category": "section",
    "text": "Records describe a set of log Attributes that should be available to a Formatter on every log message.NOTE: The Attribute type is used as a way to provide lazy evaluation of log record elements.While the DefaultRecord in Memento provides many of the keys and values needed for most logging applications, you may need to implement your own Record type. For example, if you\'re running a julia application on a cloud service provider like Amazon\'s EC2 you might want to include some general information about the resource your code is running on, which might result in a custom Record type that looks like:# TODO: Fix this example.\nmutable struct EC2Record <: Record\n    date::Attribute\n    level::Attribute\n    levelnum::Attribute\n    msg::Attribute\n    name::Attribute\n    pid::Attribute\n    lookup::Attribute\n    stacktrace::Attribute\n    instance_id::Attribute\n    public_ip::Attribute\n    iam_user::Attribute\n\n    function EC2Record(name::AbstractString, level::AbstractString, msg)\n        time = now()\n        trace = Attribute(StackTrace, get_trace)\n\n        EC2Record(\n            Attribute(DateTime, () -> round(time, Dates.Second)),\n            Attribute(level),\n            Attribute(-1),\n            Attribute(AbstractString, get_msg(msg)),\n            Attribute(name),\n            Attribute(myid()),\n            Attribute(StackFrame, get_lookup(trace)),\n            trace,\n            Attribute(ENV[\"INSTANCE_ID\"]),\n            Attribute(ENV[\"PUBLIC_IP\"]),\n            Attribute(ENV[\"IAM_USER\"]),\n        )\n    end\nendNOTE: The above example simply assumes that you have some relevant environment variables set on the machine, but you could also query Amazon for that information."
},

{
    "location": "man/io.html#",
    "page": "IO",
    "title": "IO",
    "category": "page",
    "text": ""
},

{
    "location": "man/io.html#IO-1",
    "page": "IO",
    "title": "IO",
    "category": "section",
    "text": "Memento writes all logs to any subtype of IO including IOBuffers, LibuvStreams, Pipes, Files, etc. Memento also comes with 2 logging specific IO types.FileRoller: Does automatic log file rotation.\nSyslog: Write to syslog using the logger command. Please note that syslog output is only available on systems that have logger utility installed. (This should include both Linux and OS X, but typically excludes Windows.) Note that BSD\'s logger (used on OS X) will append a second process ID, which is the PID of the logger tool itself.To create your own IO types you need to subtype IO and implement the println and flush methods."
},

{
    "location": "man/conclusion.html#",
    "page": "Conclusion",
    "title": "Conclusion",
    "category": "page",
    "text": ""
},

{
    "location": "man/conclusion.html#Conclusion-1",
    "page": "Conclusion",
    "title": "Conclusion",
    "category": "section",
    "text": "We\'ve reviewed all the different components you can use to configure logging in you application, but how do they all fit together? Let\'s work through a sample use case that uses all of the components we\'ve discussed.NOTE: The example provided is a bit contrived for simplicity.First, let\'s start with a julia Pkg called Wrapper that runs a function wrapped in some Memento logging.# Wrapper.jl\nmodule Wrapper\n\nusing Memento\n\nfunction run(f::Function, args...; kwargs...)\n    ret = nothing\n    logger = getlogger(current_module())\n    info(logger, \"Got logger $logger\")\n\n    notice(logger, \"Running function...\")\n\n    try\n        ret = f(args...; kwargs...)\n    catch exc\n        warn(logger, exc)\n    end\n\n    return ret\nend\n\nendNow we want to start writing our application code that uses this package, but our logging requirements are very specific and Memento doesn\'t support our particular use case yet.Requirements:This will be run on Amazon EC2 instances and we want our log message to contain information about the machine the code is being run on.\nWe want our logs to be written to an HTTP REST service (kinda like Loggly), where the endpoint is of the form https://<account_uri>/<app_name>/<level>?AccessKey=<access_key>.\nWe want our logs to be written in a CSV format... for some reason.Okay, so how do we address all of those requirements using Memento\'s API?Steps:Create a custom Record type called EC2Record that stores the Amazon EC2 information to address the first requirement.\nCreate a custom IO type called REST that writes log strings to the REST endpoint to partly address the second requirement.\nCreate a custom Formatter type called CSVFormatter that converts Records to (comma, tab, etc) delimited strings.NOTE: The code below is not intended to be a working example because it assumes a fake REST service.# myapp.jl\nusing Wrapper\nusing Memento\nusing Requests  # For send logs to our fake logging REST service\n\n# Start by setting up our basic console logging for the root logger.\nlogger = Memento.config(\"info\"; fmt=\"[{level} | {name}]: {msg}\")\n\n# We create our custom EC2Record type\nmutable struct EC2Record <: Record\n    date::Attribute\n    level::Attribute\n    levelnum::Attribute\n    msg::Attribute\n    name::Attribute\n    pid::Attribute\n    lookup::Attribute\n    stacktrace::Attribute\n    instance_id::Attribute\n    public_ip::Attribute\n    iam_user::Attribute\n\n    function EC2Record(args::Dict)\n        time = now()\n        trace = Attribute(StackTrace, get_trace)\n\n        EC2Record(\n            Attribute(DateTime, () -> round(time, Dates.Second)),\n            Attribute(args[:level]),\n            Attribute(args[:levelnum]),\n            Attribute(AbstractString, get_msg(args[:msg])),\n            Attribute(args[:name]),\n            Attribute(myid()),\n            Attribute(StackFrame, get_lookup(trace)),\n            trace,\n            Attribute(ENV[\"INSTANCE_ID\"]),\n            Attribute(ENV[\"PUBLIC_IP\"]),\n            Attribute(ENV[\"IAM_USER\"]),\n        )\n    end\nend\n\n# A really simple CSVFormatter\nmutable struct CSVFormatter <: Formatter\n    delim::Char\n    vals::Array{Symbol}\n\n    CSVFormatter(delim=\',\', vals=Array{Symbol}()) = new(delim, vals)\nend\n\nfunction format(fmt::CSVFormatter, rec::Record)\n    fields = isempty(fmt.vals) ? keys(rec) : fmt.vals\n\n    # For a real world use case we might want to do some\n    # string formatting of fields like :stacktrace here.\n\n    val = map(k -> rec[k], fields)\n\n    return join(val, fmt.delim)\nend\n\n# Create our custom REST IO type\nmutable struct REST <: IO\n    account_uri::AbstractString\n    app_name::AbstractString\n    access_key::AbstractString\nend\n\n# Our print method builds the correct uri using the log level\n# and sends the put request.\nfunction println(io::REST, level::AbstractString, msg::AbstractString)\n    uri = \"https://$(io.account_uri)/$(io.app_name)/$level?AccessKey=$(io.access_key)\"\n    @async put(uri; data=msg)\nend\n\n# Not relevant, but good to have.\nflush(io::REST) = io\n\n# We still need to special case the `DefaultHandler` `log` method to call  `println(io::REST, level, msg)`\nfunction log(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:REST}\n    msg = format(handler.fmt, rec)\n    println(handler.io, rec[:level], msg)\n    flush(handler.io)\nend\n\n# Now we can tie this all together, but adding a new DefaultHandler\n# with the CSVFormatter and REST IO type.\npush!(\n    logger,\n    DefaultHandler(\n        REST(\n            \"memento.mylogrestservice.com\", \"myapp\",\n            \"qM033cSYWTuu8VpXFSZm9QMm9ZESOU2A\"\n        ),\n        CSVFormatter(\n            \',\',\n            [:date, :name, :level, :msg, :iam_user, :public_ip, :instance_id]\n        )\n    )\n)\n\n# Don\'t forget to update the root logger `Record` type.\nsetrecord!(logger, EC2Record)\n\nWrapper.run(exp, 10)\n# Should log some things.\n\nWrapper.run(exp, \"foo\")\n# Should log a warning about a method error."
},

{
    "location": "faq/another-logging-lib.html#",
    "page": "Another logging library?",
    "title": "Another logging library?",
    "category": "page",
    "text": ""
},

{
    "location": "faq/another-logging-lib.html#Another-logging-library?-1",
    "page": "Another logging library?",
    "title": "Another logging library?",
    "category": "section",
    "text": "...or why did you fork Lumberjack.jl?The short answer is that none of the existing logging libraries quite fit our requirements. The summary table provided below shows that all of the existing libraries are missing more than 1 requirement. Our initial goal was to add more tests, hierarchical logging and some API changes to Lumberjack as it seemed to have the best balance of features and test coverage. In the end, our changes diverged enough from Lumberjack that it made more sense to fork the project.Properties Logging.jl Lumberjack.jl MiniLogging.jl Memento.jl\nVersions 0.3.1 2.1.0 0.0.2 N/A\nCoverage 61% 76% 87% 100%\nUnix Yes Yes Yes Yes\nWindows Yes No No Yes\nJulia 0.4, 0.5 0.4, 0.5 0.5 0.5\nHierarchical Kinda No Yes Yes\nCustom Formatting No Kinda No Yes\nCustom IO Types Yes Yes Yes Yes\nSyslog Yes Yes No Yes\nColor Yes Yes No YesYou can see from the table that Memento covers all of our logging requirements and has significantly higher test coverage."
},

{
    "location": "faq/change-colors.html#",
    "page": "Changing colors?",
    "title": "Changing colors?",
    "category": "page",
    "text": ""
},

{
    "location": "faq/change-colors.html#Changing-colors?-1",
    "page": "Changing colors?",
    "title": "Changing colors?",
    "category": "section",
    "text": "Colors can be enabled/disabled and set using via the is_colorized and colors options to the DefaultHandler.julia> add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(:is_colorized => true)),\n    \"console\"\n)Will create a DefaultHandler with colorizationBy default the following colors are used:Dict{AbstractString, Symbol}(\n    \"debug\" => :blue,\n    \"info\" => :green,\n    \"notice\" => :cyan,\n    \"warn\" => :magenta,\n    \"error\" => :red,\n    \"critical\" => :yellow,\n    \"alert\" => :white,\n    \"emergency\" => :black,\n)However, you can specify custom colors/log levels like so:add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(\n        :colors => Dict{AbstractString, Symbol}(\n            \"debug\" => :black,\n            \"info\" => :blue,\n            \"warn\" => :yellow,\n            \"error\" => :red,\n            \"crazy\" => :green\n        )\n    ),\n    \"console\"\n)You can also globally disable colorization when running Memento.configjulia> Memento.config(\"info\"; fmt=\"[{date} | {level} | {name}]: {msg}\", colorized=false)"
},

{
    "location": "faq/logging-to-syslog.html#",
    "page": "Logging to Syslog?",
    "title": "Logging to Syslog?",
    "category": "page",
    "text": ""
},

{
    "location": "faq/logging-to-syslog.html#Logging-to-Syslog?-1",
    "page": "Logging to Syslog?",
    "title": "Logging to Syslog?",
    "category": "section",
    "text": "In Memento v0.4, the builtin Syslog type was moved into its own package Syslogs.jl which allows folks to use either Syslogs.jl or Memento.jl independently from one another. Unfortunately, this does require the following bit of glue code in your projects.# Load up `Syslogs.jl` where `Syslog` will be exported by default.\nusing Syslogs\n\n# Define a 2 line glue method as the `Syslog` type requires a level argument be passed into\n# the `println` method.\nfunction Memento.emit(handler::DefaultHandler{F, O}, rec::Record) where {F<:Formatter, O<:Syslog}\n    println(handler.io, rec[:level], format(handler.fmt, rec))\n    flush(handler.io)\nend\n\n# NOTE: This glue code is only necessary because Julia (as of v0.7) doesn\'t provide a good\n# mechanism for handling optional dependencies.Now we can start logging to syslog locally:add_handler(\n    logger,\n    DefaultHandler(\n        Syslog(),\n        DefaultFormatter(\"{level}: {msg}\")\n    ),\n    \"Syslog\"\n)We can also log to remote syslog servers via UDP or TCP:add_handler(\n    logger,\n    DefaultHandler(\n        Syslog(ip\"123.34.56.78\"),\n        DefaultFormatter(\"{level}: {msg}\")\n    ),\n    \"Syslog\"\n)"
},

{
    "location": "faq/json-formatting.html#",
    "page": "Producing JSON logs?",
    "title": "Producing JSON logs?",
    "category": "page",
    "text": ""
},

{
    "location": "faq/json-formatting.html#Producing-JSON-logs?-1",
    "page": "Producing JSON logs?",
    "title": "Producing JSON logs?",
    "category": "section",
    "text": "In Memento v0.4, the JsonFormatter type was converted into a more general DictFormatter which allowed us to drop JSON.jl as a dependency. However, the original behaviour can still be easily achieved by passing in JSON.json to the DictFormatter constructor.using JSON\n\nadd_handler(\n    logger,\n    DefaultHandler(\n        \"json-output.log\",\n        DictFormatter(JSON.json)\n    ),\n    \"JSON\"\n)"
},

{
    "location": "faq/pkg-usage.html#",
    "page": "Using Memento in Julia packages?",
    "title": "Using Memento in Julia packages?",
    "category": "page",
    "text": ""
},

{
    "location": "faq/pkg-usage.html#Using-Memento-in-Julia-packages?-1",
    "page": "Using Memento in Julia packages?",
    "title": "Using Memento in Julia packages?",
    "category": "section",
    "text": "Some care needs to be taken when working with Memento from precompiled modules. Specifically, it is important to note that if you want folks be able to configure your logger from outside the module you\'ll want to register the logger in your __init__() method.__precompile__() # this module is safe to precompile\nmodule MyModule\n\nusing Memento\n\n# Create our module level logger (this will get precompiled)\nconst LOGGER = get_logger(current_module())   # or `get_logger(@__MODULE__)` on 0.7\n\n# Register the module level logger at runtime so that folks can access the logger via `get_logger(MyModule)`\n# NOTE: If this line is not included then the precompiled `MyModule.LOGGER` won\'t be registered at runtime.\n__init__() = Memento.register(LOGGER)\n\nend"
},

{
    "location": "api/public.html#",
    "page": "Public",
    "title": "Public",
    "category": "page",
    "text": ""
},

{
    "location": "api/public.html#Public-1",
    "page": "Public",
    "title": "Public",
    "category": "section",
    "text": ""
},

{
    "location": "api/public.html#Memento.Logger",
    "page": "Public",
    "title": "Memento.Logger",
    "category": "type",
    "text": "Logger\n\nA Logger is responsible for converting msg strings into Records which are then passed to each handler. By default loggers propagate their message to their parent loggers.\n\nFields\n\nname::AbstractString: is the name of the logger (required).\nhandlers::Dict{Any, Handler}: is a collection of Handlers (defaults to empty Dict).\nlevel::AbstractString: the current minimum logging level for the logger to  log message to handlers (defaults to \"not_set\").\nlevels::Dict{AbstractString, Int}: a mapping of available logging levels to their   relative priority (represented as integer values) (defaults to using Memento._log_levels)\nrecord::Type: the Record type that should be produced by this logger   (defaults to DefaultRecord).\npropagate::Bool: whether or not this logger should propagate its message to its parent   (defaults to true).\n\n\n\n"
},

{
    "location": "api/public.html#Base.error",
    "page": "Public",
    "title": "Base.error",
    "category": "function",
    "text": "error(logger::Logger, msg::AbstractString)\n\nLogs the message at the error level and throws an ErrorException with that message\n\nerror(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the error level and throws an ErrorException with that message.\n\nerror(logger::Logger, exc::Exception)\n\nCalls error(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.addlevel!-Tuple{Memento.Logger,AbstractString,Int64}",
    "page": "Public",
    "title": "Memento.addlevel!",
    "category": "method",
    "text": "addlevel!(logger::Logger, level::AbstractString, val::Int)\n\nAdds a new level::String and priority::Int to the logger.levels\n\n\n\n"
},

{
    "location": "api/public.html#Memento.alert",
    "page": "Public",
    "title": "Memento.alert",
    "category": "function",
    "text": "alert(logger::Logger, msg::AbstractString)\n\nLogs the message at the alert level and throws an ErrorException with that message\n\nalert(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the alert level and throws an ErrorException with that message.\n\nalert(logger::Logger, exc::Exception)\n\nCalls alert(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.critical",
    "page": "Public",
    "title": "Memento.critical",
    "category": "function",
    "text": "critical(logger::Logger, msg::AbstractString)\n\nLogs the message at the critical level and throws an ErrorException with that message\n\ncritical(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the critical level and throws an ErrorException with that message.\n\ncritical(logger::Logger, exc::Exception)\n\nCalls critical(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.debug",
    "page": "Public",
    "title": "Memento.debug",
    "category": "function",
    "text": "debug(logger::Logger, msg::AbstractString)\n\nLogs the message at the debug level.\n\ndebug(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the debug level.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.emergency",
    "page": "Public",
    "title": "Memento.emergency",
    "category": "function",
    "text": "emergency(logger::Logger, msg::AbstractString)\n\nLogs the message at the emergency level and throws an ErrorException with that message\n\nemergency(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the emergency level and throws an ErrorException with that message.\n\nemergency(logger::Logger, exc::Exception)\n\nCalls emergency(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.getfilters-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.getfilters",
    "category": "method",
    "text": "getfilters(logger::Logger) -> Array{Filter}\n\nReturns the filters for the logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.gethandlers-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.gethandlers",
    "category": "method",
    "text": "gethandlers(logger::Logger)\n\nReturns logger.handlers\n\n\n\n"
},

{
    "location": "api/public.html#Memento.getlevel-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.getlevel",
    "category": "method",
    "text": "getlevel(::Logger)\n\nReturns the current logger level.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.getlogger",
    "page": "Public",
    "title": "Memento.getlogger",
    "category": "function",
    "text": "getlogger(name::AbstractString) -> Logger\n\nIf the logger or its parents do not exist then they are initialized with no handlers and not set.\n\nArguments\n\nname::AbstractString: the name of the logger (defaults to \"root\")\n\nReturns\n\nLogger: the logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.getlogger-Tuple{Module}",
    "page": "Public",
    "title": "Memento.getlogger",
    "category": "method",
    "text": "getlogger(name::Module) -> Logger\n\nConverts the Module to a String and calls get_logger(name::String).\n\nArguments\n\nname::Module: the Module a logger should be associated\n\nReturns\n\nLogger: the logger associated with the provided Module.\n\nReturns the logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.ispropagating-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.ispropagating",
    "category": "method",
    "text": "ispropagating(::Logger)\n\nReturns true or false as to whether the logger is propagating.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.isroot-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.isroot",
    "category": "method",
    "text": "isroot(::Logger)\n\nReturns true if logger.nameis \"root\" or \"\"\n\n\n\n"
},

{
    "location": "api/public.html#Memento.isset-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.isset",
    "category": "method",
    "text": "isset(::Logger)\n\nReturns true or false as to whether the logger is set. (ie: logger.level != \"not_set\")\n\n\n\n"
},

{
    "location": "api/public.html#Memento.notice",
    "page": "Public",
    "title": "Memento.notice",
    "category": "function",
    "text": "notice(logger::Logger, msg::AbstractString)\n\nLogs the message at the notice level.\n\nnotice(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the notice level.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.setlevel!-Tuple{Function,Memento.Logger,AbstractString}",
    "page": "Public",
    "title": "Memento.setlevel!",
    "category": "method",
    "text": "setlevel!(f::Function, logger::Logger, level::AbstractString)\n\nTemporarily change the level a logger will log at for the duration of the function f.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.setlevel!-Tuple{Memento.Logger,AbstractString}",
    "page": "Public",
    "title": "Memento.setlevel!",
    "category": "method",
    "text": "setlevel!(logger::Logger, level::AbstractString)\n\nChanges what level this logger should log at.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.setpropagating!",
    "page": "Public",
    "title": "Memento.setpropagating!",
    "category": "function",
    "text": "setpropagating!(::Logger, [::Bool])\n\nSets the logger to be propagating or not (Defaults to true).\n\n\n\n"
},

{
    "location": "api/public.html#Memento.setrecord!-Union{Tuple{Memento.Logger,Type{R}}, Tuple{R}} where R<:Memento.Record",
    "page": "Public",
    "title": "Memento.setrecord!",
    "category": "method",
    "text": "setrecord!{R<:Record}(logger::Logger, rec::Type{R})\n\nSets the record type for the logger.\n\nArguments\n\nlogger::Logger: the logger to set.\nrec::Record: A Record type to use for logging messages (ie: DefaultRecord).\n\n\n\n"
},

{
    "location": "api/public.html#Loggers-1",
    "page": "Public",
    "title": "Loggers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"loggers.jl\"]"
},

{
    "location": "api/public.html#Memento.DefaultHandler",
    "page": "Public",
    "title": "Memento.DefaultHandler",
    "category": "type",
    "text": "DefaultHanlder\n\nThe DefaultHandler manages any Formatter, IO and Record.\n\nFields:\n\nfmt: a Formatter for converting Records to Strings\nio: an IO type for printing String to.\nopts: a dictionary of optional arguments such as :is_colorized and :colors   Ex) Dict{Symbol, Any}(           :is_colorized => true,           :opts[:colors] => Dict{AbstractString, Symbol}(               \"debug\" => :blue,               \"info\" => :green,               ...           )       )\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DefaultHandler-Union{Tuple{AbstractString,F,Any}, Tuple{AbstractString,F}, Tuple{AbstractString}, Tuple{F}} where F<:Memento.Formatter",
    "page": "Public",
    "title": "Memento.DefaultHandler",
    "category": "method",
    "text": "DefaultHandler{F}(filename::AbstractString, fmt::F, opts::Dict{Symbol, Any}) where {F<Formatter}\n\nCreates a DefaultHandler with a IO handle to the specified filename.\n\nArguments\n\nfilename::AbstractString: the filename of a log file to write to\nfmt::Formatter: the Formatter to use (default to DefaultFormatter())\nopts::Dict: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DefaultHandler-Union{Tuple{F}, Tuple{O,F,Any}, Tuple{O,F}, Tuple{O}, Tuple{O}} where O<:IO where F<:Memento.Formatter",
    "page": "Public",
    "title": "Memento.DefaultHandler",
    "category": "method",
    "text": "DefaultHandler{F, O}(io::O, fmt::F, opts::Dict{Symbol, Any}) where {F<Formatter, O<:IO}\n\nCreates a DefaultHandler with the specified IO type.\n\nArguments\n\nio::IO: the IO type\nfmt::Formatter: the Formatter to use (default to DefaultFormatter())\nopts::Dict: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Handler",
    "page": "Public",
    "title": "Memento.Handler",
    "category": "type",
    "text": "Handler\n\nManage formatting Records and printing the resulting String to an IO type. All Handler subtypes must implement at least 1 log(::Handler, ::Record) method.\n\nNOTE: Handlers can useful if you need to special case logging behaviour based on the Formatter, IO and/or Record types.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.emit-Union{Tuple{F}, Tuple{Memento.DefaultHandler{F,O},Memento.Record}, Tuple{O}} where O<:IO where F<:Memento.Formatter",
    "page": "Public",
    "title": "Memento.emit",
    "category": "method",
    "text": "emit{F, O}(handler::DefaultHandler{F ,O}, rec::Record) where {F<:Formatter, O<:IO}\n\nHandles printing any Record with any Formatter and IO types.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.getfilters-Tuple{Memento.DefaultHandler}",
    "page": "Public",
    "title": "Memento.getfilters",
    "category": "method",
    "text": "getfilters(handler::DefaultHandler) -> Array{Filter}\n\nReturns the filters for the handler.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.setlevel!-Tuple{Memento.DefaultHandler,AbstractString}",
    "page": "Public",
    "title": "Memento.setlevel!",
    "category": "method",
    "text": "setlevel!(handler::DefaultHandler, level::AbstractString)\n\nSets the minimum level required to emit the record from the handler.\n\n\n\n"
},

{
    "location": "api/public.html#Handlers-1",
    "page": "Public",
    "title": "Handlers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"handlers.jl\"]"
},

{
    "location": "api/public.html#Memento.DefaultFormatter",
    "page": "Public",
    "title": "Memento.DefaultFormatter",
    "category": "type",
    "text": "DefaultFormatter\n\nThe DefaultFormatter uses a simple format string to build the log message. Fields from the Record to be used should be wrapped curly brackets.\n\nEx) \"[{level} | {name}]: {msg}\" will print message of the form [info | root]: my info message. [warn | root]: my warning message. ...\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DictFormatter-Tuple{}",
    "page": "Public",
    "title": "Memento.DictFormatter",
    "category": "method",
    "text": "DictFormatter([aliases, serializer])\n\nFormats the record to Dict that is amenable to serialization formats such as JSON and then runs the serializer function on the produced dictionary.\n\nArguments\n\naliases::Dict{Symbol, Symbol}: Mapping where the keys represent aliases and values represent existing record attributes to include in the dictionary (defaults to all attributes).\nserializer::Function: A function that takes a Dictionary and returns a string. Defaults to string(dict).\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Formatter",
    "page": "Public",
    "title": "Memento.Formatter",
    "category": "type",
    "text": "Formatter\n\nA Formatter must implement a format(::Formatter, ::Record) method which takes a Record and returns a String representation of the log Record.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.format-Tuple{Memento.DefaultFormatter,Memento.Record}",
    "page": "Public",
    "title": "Memento.format",
    "category": "method",
    "text": "format(::DefaultFormatter, ::Record) -> String\n\nIteratively replaces entries in the format string with the appropriate fields in the Record\n\n\n\n"
},

{
    "location": "api/public.html#Memento.format-Tuple{Memento.DictFormatter,Memento.Record}",
    "page": "Public",
    "title": "Memento.format",
    "category": "method",
    "text": "format(::DictFormatter, ::Record) -> Dict\n\nConverts :date, :lookup and :stacktrace to strings and dicts respectively.\n\n\n\n"
},

{
    "location": "api/public.html#Formatters-1",
    "page": "Public",
    "title": "Formatters",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"formatters.jl\"]"
},

{
    "location": "api/public.html#Memento.DefaultRecord",
    "page": "Public",
    "title": "Memento.DefaultRecord",
    "category": "type",
    "text": "DefaultRecord\n\nStores the most common logging event information. NOTE: if you\'d like more logging attributes you can:\n\nadd them to DefaultRecord and open a pull request if the new attributes are applicable to most applications.\nmake a custom Record type.\n\nFields\n\ndate::Attribute{DateTime}: timestamp of log event\nlevel::Attribute{Symbol}: log level\nlevelnum::Attribute{Int}: integer value for log level\nmsg::Attribute{AbstractString}: the log message itself\nname::Attribute{AbstractString}: the name of the source logger\npid::Attribute{Int}: the pid of where the log event occured\nlookup::Attribute{StackFrame}: the top StackFrame\nstacktrace::Attribute{StackTrace}: a stacktrace\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DefaultRecord-Tuple{AbstractString,AbstractString,Int64,Any}",
    "page": "Public",
    "title": "Memento.DefaultRecord",
    "category": "method",
    "text": "DefaultRecord(name::AbstractString, level::AbstractString, msg::AbstractString)\n\nTakes a few initial log record arguments and creates a DefaultRecord.\n\nArguments\n\nname::AbstractString: the name of the source logger.\nlevel::AbstractString: the log level.\nmsg::AbstractString: the message being logged.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Record",
    "page": "Public",
    "title": "Memento.Record",
    "category": "type",
    "text": "Record\n\nAre an Attribute container used to store information about a log events including the msg, date, level, stacktrace, etc. Formatters use Records to format log message strings.\n\nNOTE: you should access Attributes in a Record by using getindex (ie: record[:msg]) as this will correctly extract the value from the Attribute container.\n\n\n\n"
},

{
    "location": "api/public.html#Records-1",
    "page": "Public",
    "title": "Records",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"records.jl\"]"
},

{
    "location": "api/public.html#Memento.FileRoller",
    "page": "Public",
    "title": "Memento.FileRoller",
    "category": "type",
    "text": "FileRoller <: IO\n\nIs responsible for managing a rolling log file.\n\nFields\n\nprefix::AbstractString: filename prefix for the log.\nfolder::AbstractString: directory where the log should be written.\nfile::AbstractString: the current file IO handle\nbyteswritten::Int64: keeps track of how many bytes have been written to the current file.\nmax_sz::Int: the maximum number of bytes written to a file before rolling over to another.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.FileRoller-Tuple{Any,Any}",
    "page": "Public",
    "title": "Memento.FileRoller",
    "category": "method",
    "text": "FileRoller(prefix, dir; max_size=DEFAULT_MAX_FILE_SIZE)\n\nCreates a rolling log file in the specified directory with the given prefix.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.FileRoller-Tuple{Any}",
    "page": "Public",
    "title": "Memento.FileRoller",
    "category": "method",
    "text": "FileRoller(prefix; max_size=DEFAULT_MAX_FILE_SIZE)\n\nCreates a rolling log file in the current working directory with the specified prefix.\n\n\n\n"
},

{
    "location": "api/public.html#IO-1",
    "page": "Public",
    "title": "IO",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"io.jl\"]"
},

{
    "location": "api/private.html#",
    "page": "Private",
    "title": "Private",
    "category": "page",
    "text": ""
},

{
    "location": "api/private.html#Private-1",
    "page": "Private",
    "title": "Private",
    "category": "section",
    "text": ""
},

{
    "location": "api/private.html#Base.info",
    "page": "Private",
    "title": "Base.info",
    "category": "function",
    "text": "info(logger::Logger, msg::AbstractString)\n\nLogs the message at the info level.\n\ninfo(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the info level.\n\n\n\n"
},

{
    "location": "api/private.html#Base.log-Tuple{Function,Memento.Logger,AbstractString}",
    "page": "Private",
    "title": "Base.log",
    "category": "method",
    "text": "log(::Function, ::Logger, ::AbstractString)\n\nSame as log(logger, level, msg), but in this case the message can be a function that returns the log message string.\n\nArguments\n\nmsg::Function: a function that returns a message String\nlogger::Logger: the logger to log to.\nlevel::AbstractString: the log level as a String\n\nThrows\n\nCompositeException: may be thrown if an error occurs in one of the handlers  (which are run with @async)\n\n\n\n"
},

{
    "location": "api/private.html#Base.log-Tuple{Memento.Logger,AbstractString,AbstractString}",
    "page": "Private",
    "title": "Base.log",
    "category": "method",
    "text": "log(logger::Logger, level::AbstractString, msg::AbstractString)\n\nCreates a Dict with the logger name, level, levelnum and message and calls the other log method (which may recursively call itself on parent loggers with the created Dict).\n\nArguments\n\nlogger::Logger: the logger to log to.\nlevel::AbstractString: the log level as a String\nmsg::AbstractString: the msg to log as a String\n\nThrows\n\nCompositeException: may be thrown if an error occurs in one of the handlers  (which are run with @async)\n\n\n\n"
},

{
    "location": "api/private.html#Base.log-Tuple{Memento.Logger,Memento.Record}",
    "page": "Private",
    "title": "Base.log",
    "category": "method",
    "text": "log(logger::Logger, args::Dict{Symbol, Any})\n\nLogs logger.record(args) to its handlers if it has the appropriate args[:level] and args[:level] is above the priority of logger.level. If this logger is not the root logger and logger.propagate is true then the parent logger is called.\n\nNOTE: This method calls all handlers asynchronously and is recursive, so you should call this method with a @sync in order to synchronize all handler tasks.\n\nArguments\n\nlogger::Logger: the logger to log args to.\nargs::Dict: a dict of msg fields and values that should be passed to logger.record.\n\n\n\n"
},

{
    "location": "api/private.html#Base.push!-Tuple{Memento.Logger,Memento.Filter}",
    "page": "Private",
    "title": "Base.push!",
    "category": "method",
    "text": "push!(logger::Logger, filter::Memento.Filter)\n\nAdds an new Filter to the logger.\n\n\n\n"
},

{
    "location": "api/private.html#Base.push!-Tuple{Memento.Logger,Memento.Handler}",
    "page": "Private",
    "title": "Base.push!",
    "category": "method",
    "text": "push!(logger::Logger, handler::Handler)\n\nAdds a new Handler to the logger.\n\n\n\n"
},

{
    "location": "api/private.html#Base.show-Tuple{IO,Memento.Logger}",
    "page": "Private",
    "title": "Base.show",
    "category": "method",
    "text": "Base.show(::IO, ::Logger)\n\nJust prints Logger(logger.name)\n\n\n\n"
},

{
    "location": "api/private.html#Base.warn",
    "page": "Private",
    "title": "Base.warn",
    "category": "function",
    "text": "warn(logger::Logger, msg::AbstractString)\n\nLogs the message at the warn level.\n\nwarn(msg::Function, logger::Logger)\n\nLogs the message produced by the provided function at the warn level.\n\n\n\n"
},

{
    "location": "api/private.html#Base.warn-Tuple{Memento.Logger,Exception}",
    "page": "Private",
    "title": "Base.warn",
    "category": "method",
    "text": "warn(logger::Logger, exc::Exception)\n\nTakes an exception and logs it.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.config-Tuple{AbstractString}",
    "page": "Private",
    "title": "Memento.config",
    "category": "method",
    "text": "config([logger], level; fmt::AbstractString, levels::Dict{AbstractString, Int}, colorized::Bool) -> Logger\n\nSets the Memento._log_levels, creates a default root logger with a DefaultHandler that prints to STDOUT.\n\nArguments\n\n\'logger::Union{Logger, AbstractString}`: The logger to configure (optional)\nlevel::AbstractString: the minimum logging level to log message to the root logger (required).\nfmt::AbstractString: a format string to pass to the DefaultFormatter which describes   how to log messages (defaults to Memento.DEFAULT_FMT_STRING)\nlevels: the default logging levels to use (defaults to Memento._log_levels).\ncolorized: whether or not the message to STDOUT should be colorized.\n\nReturns\n\nLogger: the root logger.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getparent-Tuple{Any}",
    "page": "Private",
    "title": "Memento.getparent",
    "category": "method",
    "text": "getparent(name::AbstractString) -> Logger\n\nTakes a string representing the name of a logger and returns its parent. If the logger name has no parent then the root logger is returned. Parent loggers are extracted assuming a naming convention of \"foo.bar.baz\", where \"foo.bar.baz\" is the child of \"foo.bar\" which is the child of \"foo\"\n\nArguments\n\nname::AbstractString: the name of the logger.\n\nReturns\n\nLogger: the parent logger.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.register-Tuple{Memento.Logger}",
    "page": "Private",
    "title": "Memento.register",
    "category": "method",
    "text": "register(::Logger)\n\nRegister an existing logger with Memento.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.reset!-Tuple{}",
    "page": "Private",
    "title": "Memento.reset!",
    "category": "method",
    "text": "reset!()\n\nRemoves all registered loggers and reinitializes the root logger without any handlers.\n\n\n\n"
},

{
    "location": "api/private.html#Loggers-1",
    "page": "Private",
    "title": "Loggers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"loggers.jl\"]"
},

{
    "location": "api/private.html#Base.log-Tuple{Memento.Handler,Memento.Record}",
    "page": "Private",
    "title": "Base.log",
    "category": "method",
    "text": "log(handler::Handler, rec::Record)\n\nChecks the Handler filters and if they all pass then emit the record.\n\n\n\n"
},

{
    "location": "api/private.html#Base.push!-Tuple{Memento.DefaultHandler,Memento.Filter}",
    "page": "Private",
    "title": "Base.push!",
    "category": "method",
    "text": "push!(handler::DefaultHandler, filter::Memento.Filter)\n\nAdds an new Filter to the handler.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.setup_opts-Tuple{Any}",
    "page": "Private",
    "title": "Memento.setup_opts",
    "category": "method",
    "text": "setup_opts(opts) -> Dict\n\nSets the default :colors if opts[:is_colorized] == true.\n\n\n\n"
},

{
    "location": "api/private.html#Handlers-1",
    "page": "Private",
    "title": "Handlers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"handlers.jl\"]"
},

{
    "location": "api/private.html#Formatters-1",
    "page": "Private",
    "title": "Formatters",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"formatters.jl\"]"
},

{
    "location": "api/private.html#Base.Dict-Tuple{Memento.Record}",
    "page": "Private",
    "title": "Base.Dict",
    "category": "method",
    "text": "Dict(rec::Record)\n\nExtracts the Record and its Attributes into a Dict NOTE: This may be an expensive operations, so you probably don\'t want to do this for every log record unless you\'re planning on using every Attribute.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.Attribute",
    "page": "Private",
    "title": "Memento.Attribute",
    "category": "type",
    "text": "Attribute\n\nAn Attribute represents a lazily evaluated field in a log Record.\n\nFields\n\nf::Function: A function to evaluate in order to get a value if one is not set.\nx::Nullable: A value that may or may not exist yet.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.Attribute-Tuple{Any}",
    "page": "Private",
    "title": "Memento.Attribute",
    "category": "method",
    "text": "Attribute(x)\n\nSimply wraps the value x in a Nullable and sticks that in an Attribute with an empty Function.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.Attribute-Tuple{Type,Function}",
    "page": "Private",
    "title": "Memento.Attribute",
    "category": "method",
    "text": "Attribute(T::Type, f::Function)\n\nCreates an Attribute with the function and a Nullable of type T.\n\n\n\n"
},

{
    "location": "api/private.html#Base.get-Tuple{Memento.Attribute}",
    "page": "Private",
    "title": "Base.get",
    "category": "method",
    "text": "get(attr::Attribute{T}) -> T\n\nRun set attr.x to the output of attr.f if attr.x is not already set. We then return the value stored in attr.x\n\n\n\n"
},

{
    "location": "api/private.html#Memento.get_lookup-Tuple{Memento.Attribute{Array{StackFrame,1}}}",
    "page": "Private",
    "title": "Memento.get_lookup",
    "category": "method",
    "text": "get_lookup(trace::Attribute{StackTrace})\n\nReturns the top StackFrame for trace if it isn\'t empty.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.get_msg-Tuple{Any}",
    "page": "Private",
    "title": "Memento.get_msg",
    "category": "method",
    "text": "get_msg(msg) -> Function\n\nWraps msg in a function if it is a String.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.get_trace-Tuple{}",
    "page": "Private",
    "title": "Memento.get_trace",
    "category": "method",
    "text": "get_trace()\n\nReturns the StackTrace with StackFrames from the Memento module filtered out.\n\n\n\n"
},

{
    "location": "api/private.html#Records-1",
    "page": "Private",
    "title": "Records",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"records.jl\"]"
},

{
    "location": "api/private.html#Base.flush-Tuple{Memento.FileRoller}",
    "page": "Private",
    "title": "Base.flush",
    "category": "method",
    "text": "flush(::FileRoller)\n\nFlushes the current open file.\n\n\n\n"
},

{
    "location": "api/private.html#Base.println-Tuple{Memento.FileRoller,AbstractString}",
    "page": "Private",
    "title": "Base.println",
    "category": "method",
    "text": "println(::FileRoller, ::AbstractString)\n\nWrites the string to a file and creates a new file if we\'ve reached the max file size.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getfile-Tuple{AbstractString,AbstractString}",
    "page": "Private",
    "title": "Memento.getfile",
    "category": "method",
    "text": "getfile(folder::AbstractString, prefix::AbstractString) -> String, IO\n\nGrabs the next log file.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getsuffix-Tuple{Integer}",
    "page": "Private",
    "title": "Memento.getsuffix",
    "category": "method",
    "text": "getsuffix(::Integer) -> String\n\nFormats the nth file suffix.\n\n\n\n"
},

{
    "location": "api/private.html#IO-1",
    "page": "Private",
    "title": "IO",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"io.jl\"]"
},

{
    "location": "contributing.html#",
    "page": "Contributing",
    "title": "Contributing",
    "category": "page",
    "text": ""
},

{
    "location": "contributing.html#Get-started-contributing-1",
    "page": "Contributing",
    "title": "Get started contributing",
    "category": "section",
    "text": "Detailed docs on contributing to Julia packages can be found here."
},

{
    "location": "contributing.html#Code-and-docs-1",
    "page": "Contributing",
    "title": "Code and docs",
    "category": "section",
    "text": "To start hacking code or writing docs, simply:julia> Pkg.add(\"Memento\"); Pkg.checkout(\"Memento\")\nMake your changes.\nTest your changes with julia --compilecache=no -e \'Pkg.test(\"Memento\"; coverage=true)\'\nCheck that your changes haven\'t reduced the test coverage. From the root Memento package folder run julia -e \'using Coverage; Coverage.get_summary(process_folder())\'.\nMake a pull request to Memento and share your changes with the rest of the community."
},

{
    "location": "contributing.html#Bugs,-features,-and-requests-1",
    "page": "Contributing",
    "title": "Bugs, features, and requests",
    "category": "section",
    "text": "Feel free to file issues when you encounter bugs, think of interesting features you\'d like to see, or when there are important changes not yet included in a release and you\'d like us to tag a new version."
},

{
    "location": "contributing.html#Submitting-your-contributions-1",
    "page": "Contributing",
    "title": "Submitting your contributions",
    "category": "section",
    "text": "By contributing code to Memento, you are agreeing to release your work under the MIT License.We love contributions in the form of pull requests! Assuming you\'ve been working in a repo checked out as above, this should be easy to do. For a detailed walkthrough, check here, otherwise:Navigate to Memento.jl and create a fork.\ngit remote add origin https://github.com/user/Memento.jl.git\ngit push origin master\nSubmit your changes as a pull request!For pull requests to be accepted we require that the changes:Pass on travis and appveyor\nMaintain 100% test coverage"
},

]}
