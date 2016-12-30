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
    "text": "Start by using Mementojulia> using MementoNow setup basic logging on the root logger with basic_config.julia> logger = basic_config(\"debug\"; fmt=\"[{level} | {name}]: {msg}\")\nLogger(root)Now start logging with the root logger.julia> debug(logger, \"Something to help you track down a bug.\")\n[debug | root]: Something to help you track down a bug.\n\njulia> info(logger, \"Something you might want to know.\")\n[info | root]: Something you might want to know.\n\njulia> notice(logger, \"This is probably pretty important.\")\n[notice | root]: This is probably pretty important.\n\njulia> warn(logger, \"This might cause an error.\")\n[warn | root]: This might cause an error.\n\njulia> warn(logger, ErrorException(\"A caught exception that we want to log as a warning.\"))\n[warn | root]: A caught exception that we want to log as a warning.\n\njulia> error(logger, \"Something that should throw an error.\")\n[error | root]: Something that should throw an error.\nERROR: Something that should throw an error.\n in error(::Memento.Logger, ::String) at /Users/rory/.julia/v0.5/Memento/src/loggers.jl:250Now maybe you want to have a different logger for each module/submodule. This allows you to have custom logging behaviour and handlers for different modules and provides easier to parse logging output.julia> child_logger = get_logger(\"Foo.bar\")\nLogger(Foo.bar)\n\njulia> set_level(child_logger, \"warn\")\n\"warn\"\n\njulia> add_handler(child_logger, DefaultHandler(tempname(), DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\")))\n\nMemento.DefaultHandler{Memento.DefaultFormatter,IOStream}(Memento.DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\"),IOStream(<file /var/folders/_6/25myjdtx2fxgjvznn19rp22m0000gn/T/julia8lonyA>),Dict{Symbol,Any}(Pair{Symbol,Any}(:is_colorized,false)))\n\njulia> debug(child_logger, \"Something that should only be printed to STDOUT on the root_logger.\")\n[debug | Foo.bar]: Something that should only be printed to STDOUT on the root_logger.\n\njulia> warn(child_logger, \"Warning to STDOUT and the log file.\")\n[warn | Foo.bar]: Warning to STDOUT and the log file.NOTE: We used get_logger(\"Foo.bar\"), but you can also do get_logger(current_module()) which allows us to avoid hard coding in logger names."
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
    "text": "You can globally set the minimum logging level with basic_config.julia>basic_config(\"debug\")Will log all messages for all loggers at or above \"debug\".julia>basic_config(\"warn\")Will only log message at or above the \"warn\" level.We can also set the logging level for specific loggers or collections of loggers if we explicitly set the level on an existing logger.julia>set_level(get_logger(\"Main\"), \"info\")Will only set the logging level to \"info\" for the \"Main\" logger and any future children of the \"Main\" logger.By default Memento has 9 logging levels.Level Number Description\nnot_set 0 Will not log anything, but may still propagate messages to its parents.\ndebug 10 Log verbose message used for debugging.\ninfo 20 Log general information about a program.\nnotice 30 Log important events that are still part of normal execution.\nwarn 40 Log warning that may cause the program to fail.\nerror 50 Log errors and throw or rethrow an error.\ncritical 60 Entire application has crashed.\nalert 70 The entire application crashed and is not recoverable. Probably need to wake up the sysadmin.\nemergency 80 System is unusable. Applications shouldn't need to call this so it may be removed in the future."
},

{
    "location": "man/intro.html#Formatting-logs-1",
    "page": "Introduction",
    "title": "Formatting logs",
    "category": "section",
    "text": "The by default Memento will use a DefaultFormatter for handlers. This Formatter takes a format string for mapping log record fields into each log message. Desired fields are wrapped in curly brackets (ie: \"{msg}\")The default format string is \"[{level} | {name}]: {msg}\" would produce message that look like[info | root]: my info message.\n[warn | root]: my warning message.\n...However, you could change this string to just \"{level}: {msg}\" which would produce message that look likeinfo: my info message.\nwarn: my warning message.\n...The simplest way to globally change the log format is with basic_configjulia> basic_config(\"debug\"; fmt=\"[{level} | {name}]: {msg}\")The following fields are available via the DefaultRecord.Field Description\ndate The log event date rounded to seconds\nlevel The log event level as a string\nlevelnum The integer value for the log event level\nmsg The source log event message\nname The name of the source logger\npid The pid where the log event occured\nlookup The top StackFrame of the stacktrace for the log event\nstacktrace A StackTrace for the log eventFor more details on the DefaultFormatter and DefaultRecord please see the API docs. More general information on Formatters and Records will be discussed later in this manual."
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
    "text": "A Logger is the primary component you use to send formatted log messages to various IO outputs. This type holds information needed to manage the process of creating and storing logs. There is a default \"root\" logger stored in global _loggers inside the Memento module. Since Memento implements hierarchical logging you should define child loggers that can be configured independently and better describe the individual components within your code. To create a new logger for you code it is recommended to do get_logger(current_module()).julia> logger = get_logger(current_module())Log messages are brought to different output streams by Handlers. From here you can add and remove handlers. To add a handler that writes to rotating log files, simply:julia> add_handler(logger, DefaultHandler(\"mylogfile.log\"), \"file-logging\")Now there is a handler named \"file-logging\", and it will write all of your logs to mylogfile.log. Your logs will still show up in the console, however, because -by default- there is a handler named \"console\" already hard at work. Remove it by calling:julia> remove_handler(logger, \"console\")The operations presented here will only apply to the current logger, leaving existing loggers (e.g., Logger(root)) unaffected. However, any child loggers of Logger(Main) (e.g., Logger(Main.Foo) will have both the \"console\" and \"file-logging\" handlers available to it.We can also set the level and Record type for our logger.julia> set_level(logger, \"warn\")Now we won't log any messages with this logger unless they are at least warning messages.julia> set_record(logger, MyRecord)Now our logger will call create MyRecords instead of DefaultRecords"
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
    "text": "As we've already seen, Handlers can be used to write log messages to different IO types. More specifically, handlers are parameterized types that describe the relationship of how Formatter and IO types are used to take a Record (a kind of specified Dict) -> convert it to a String with the Formatter and write that to an IO type.In the simplest case a Handler definition would like:type MyHandler{F<:Formatter, O<:IO} <: Handler{F, O}\n    fmt::F\n    io::O\nend\n\nfunction log{F<:Formatter, O<:IO}(handler::MyHandler{F, O}, rec::Record)\n    str = format(handler.fmt, rec)\n    println(handler.io, str)\n    flush(handler.io)\nendHowever, under some circumstances it may be necessary to customize this behaviour based on the Formatter, IO or Record types being used. For example, the Syslog IO type needs an extra level argument to its println so we special case this like so:function log{F<:Formatter, O<:Syslog}(handler::MyHandler{F, O}, rec::Record)\n    str = format(handler.fmt, rec)\n    println(handler.io, rec[:level], str)\n    flush(handler.io)\nend"
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
    "text": "Formatters describe how to take a Record and convert it into properly formatted string. Currently, there are two types of Formatters.DefaultFormatter - use a simple template string format to map keys in the Record to places in the resulting string. (ie: DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\")\nJsonFormatter - builds an appropriate formatted Dict from the Record in order to use JSON.json(dict) to produce the resulting string.You should only need to write a custom Formatter type if you're needing to produce very specific string formats regardless of the Record type being used. For example, we may want a CSVFormatter which always writes logs in a CSV Format.If you just need to customize the behaviour of an existing Formatter to a specific Record type then you should simply overload the format method for that Formatter.Ex)function Memento.format(fmt::DefaultFormatter, rec::MyRecord)\n    ...\nend"
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
    "text": "Records describe a set of key value pairs that should be available to a  Formatter on every log message.Internal DefaultRecord Dict:Dict(\n    :date => round(now(), Base.Dates.Second),\n    :level => args[:level],\n    :levelnum => args[:levelnum],\n    :msg => args[:msg],\n    :name => args[:name],\n    :pid => myid(),\n    :lookup => isempty(trace) ? nothing : first(trace),\n    :stacktrace => trace,\n)While the DefaultRecord in Memento provides many of the keys and values needed for most logging applications, you may need to implement your own Record type. For example, if you're running a julia application on a cloud service provider like Amazon's EC2 you might want to include some general information about the resource your code is running on, which might result in a custom Record type that looks like:type EC2Record <: Record\n    dict::Dict{Symbol, Any}\n\n    function EC2Record(args::Dict)\n        trace = StackTraces.remove_frames!(\n            StackTraces.stacktrace(),\n            [:DefaultRecord, :log, Symbol(\"#log#22\"), :info, :warn, :debug]\n        )\n\n        new(Dict(\n            :date => round(now(), Base.Dates.Second),\n            :level => args[:level],\n            :levelnum => args[:levelnum],\n            :msg => args[:msg],\n            :name => args[:name],\n            :pid => myid(),\n            :lookup => isempty(trace) ? nothing : first(trace),\n            :stacktrace => trace,\n            :instance_id => ENV[\"INSTANCE_ID\"],\n            :public_ip => ENV[\"PUBLIC_IP\"],\n            :iam_user => ENV[\"IAM_USER\"],\n            ...\n        ))\n    end\nendNOTE: The above example simply assumes that you have some relevant environment variables set on the machine, but you could also query Amazon for that information."
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
    "text": "Memento writes all logs to any subtype of IO including IOBuffers, LibuvStreams, Pipes, Files, etc. Memento also comes with 2 logging specific IO types.FileRoller - Does automatic log file rotation.\nSyslog - Write to syslog using the logger command. Please note that syslog output is only available on systems that have logger utility installed. (This should include both Linux and OS X, but typically excludes Windows.) Note that BSD's logger (used on OS X) will append a second process ID, which is the PID of the logger tool itself.To create your own IO types you need to subtype IO and implement the println and flush methods."
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
    "text": "Colors can be enabled/disabled and set using via the is_colorized and colors options to the DefaultHandler.julia> add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(:is_colorized => true)),\n    \"console\"\n)Will create a DefaultHandler with colorizationBy default the following colors are used:Dict{AbstractString, Symbol}(\n    \"debug\" => :blue,\n    \"info\" => :green,\n    \"notice\" => :cyan,\n    \"warn\" => :magenta,\n    \"error\" => :red,\n    \"critical\" => :yellow,\n    \"alert\" => :white,\n    \"emergency\" => :black,\n)However, you can specify custom colors/log levels like so:add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(\n        :colors => Dict{AbstractString, Symbol}(\n            \"debug\" => :black,\n            \"info\" => :blue,\n            \"warn\" => :yellow,\n            \"error\" => :red,\n            \"crazy\" => :green\n        )\n    ),\n    \"console\"\n)You can also globally disable colorization when running basic_configjulia> basic_config(\"info\"; fmt=\"[{date} | {level} | {name}]: {msg}\", colorized=false)"
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
    "category": "Type",
    "text": "A Logger is responsible for converting msg strings into Records which are then passed to each handler. By default loggers propagate their message to their parent loggers.\n\nFields:\n\nname: is the name of the logger (required).\nhandlers: is a collection of Handlers (defaults to empty Dict).\nlevel: the current minimum logging level for the logger to log message to handlers (defaults to \"not_set\").\nlevels: a mapping of available logging levels to their relative priority (represented as integer values) (defaults to using Memento._log_levels)\nrecord: the Record type that should be produced by this logger (defaults to DefaultRecord).\npropagate: whether or not this logger should propagate its message to its parent (defaults to true).\n\n\n\n"
},

{
    "location": "api/public.html#Base.error",
    "page": "Public",
    "title": "Base.error",
    "category": "Function",
    "text": "error(::Logger, ::AbstractString) logs the message at the error level and throws an ErrorException with that message error(::Logger, ::Exception) calls error(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Base.info",
    "page": "Public",
    "title": "Base.info",
    "category": "Function",
    "text": "info(::Logger, ::AbstractString) logs the message at the info level.\n\n\n\n"
},

{
    "location": "api/public.html#Base.log-Tuple{Memento.Logger,AbstractString,AbstractString}",
    "page": "Public",
    "title": "Base.log",
    "category": "Method",
    "text": "log(::Logger, ::AbstractString, ::AbstractString) creates a Dict with the logger name, level, levelnum and message and calls the other log method (which may recursively call itself on parent loggers with the created Dict).\n\nArgs:\n\nlogger: the logger to log to.\nlevel: the log level as a String\nmsg: the msg to log as a String\n\n\n\n"
},

{
    "location": "api/public.html#Base.log-Tuple{Memento.Logger,Dict{Symbol,Any}}",
    "page": "Public",
    "title": "Base.log",
    "category": "Method",
    "text": "log(::Logger, ::Dict{Symbol, Any}) logs logger.record(args) to its handlers if it has the appropriate args[:level] and args[:level] is above the priority of logger.level. If this logger is not the root logger and logger.propagate is true then the parent logger is called.\n\nArgs:\n\nlogger: the logger to log args to.\nargs: a dict of msg fields and values that should be passed to logger.record.\n\n\n\n"
},

{
    "location": "api/public.html#Base.warn",
    "page": "Public",
    "title": "Base.warn",
    "category": "Function",
    "text": "warn(::Logger, ::AbstractString) logs the message at the warn level.\n\n\n\n"
},

{
    "location": "api/public.html#Base.warn-Tuple{Memento.Logger,Exception}",
    "page": "Public",
    "title": "Base.warn",
    "category": "Method",
    "text": "warn(::Logger, ::Exception) takes an exception and logs it. \n\n\n\n"
},

{
    "location": "api/public.html#Memento.add_handler",
    "page": "Public",
    "title": "Memento.add_handler",
    "category": "Function",
    "text": "add_handler(::Logger, ::Handler, name) adds a new handler to logger.handlers. If a name is not provided a random one will be generated.\n\nArgs:\n\nlogger: the logger to use.\nhandler: the handler to add.\nname: a name to identify the handler.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.add_level-Tuple{Memento.Logger,AbstractString,Int64}",
    "page": "Public",
    "title": "Memento.add_level",
    "category": "Method",
    "text": "add_level(::Logger, ::AbstractString, ::Int) adds a new level::String and priority::Int to the logger.levels\n\n\n\n"
},

{
    "location": "api/public.html#Memento.alert",
    "page": "Public",
    "title": "Memento.alert",
    "category": "Function",
    "text": "alert(::Logger, ::AbstractString) logs the message at the alert level and throws an ErrorException with that message alert(::Logger, ::Exception) calls alert(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.basic_config-Tuple{AbstractString}",
    "page": "Public",
    "title": "Memento.basic_config",
    "category": "Method",
    "text": "basic_config(::AbstractString; ::AbstractString, ::Dict{AbstractString, Int}, colorized::Bool) sets the Memento._log_levels, creates a default root logger with a DefaultHandler that prints to STDOUT.\n\nArgs:\n\nlevel: the minimum logging level to log message to the root logger (required).\nfmt: a format string to pass to the DefaultFormatter which describes how to log messages (defaults to Memento.DEFAULT_FMT_STRING)\nlevels: the default logging levels to use (defaults to Memento._log_levels).\ncolorized: whether or not the message to STDOUT should be colorized.\n\nReturns the root logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.critical",
    "page": "Public",
    "title": "Memento.critical",
    "category": "Function",
    "text": "critical(::Logger, ::AbstractString) logs the message at the critical level and throws an ErrorException with that message critical(::Logger, ::Exception) calls critical(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.debug",
    "page": "Public",
    "title": "Memento.debug",
    "category": "Function",
    "text": "debug(::Logger, ::AbstractString) logs the message at the debug level.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.emergency",
    "page": "Public",
    "title": "Memento.emergency",
    "category": "Function",
    "text": "emergency(::Logger, ::AbstractString) logs the message at the emergency level and throws an ErrorException with that message emergency(::Logger, ::Exception) calls emergency(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.get_handlers-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.get_handlers",
    "category": "Method",
    "text": "get_handlers(::Logger) returns logger.handlers\n\n\n\n"
},

{
    "location": "api/public.html#Memento.get_logger",
    "page": "Public",
    "title": "Memento.get_logger",
    "category": "Function",
    "text": "get_logger(::AbstractString) returns the appropriate logger. If the logger or its parents do not exist then they are initialized with no handlers and not set.\n\nArgs: the name of the logger (defaults to \"root\")\n\nReturns the logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.get_logger-Tuple{Module}",
    "page": "Public",
    "title": "Memento.get_logger",
    "category": "Method",
    "text": "get_logger(name::Module) converts the Module to a String and calls get_logger(name::String).\n\nArgs: name of the logger\n\nReturns the logger.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.is_root-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.is_root",
    "category": "Method",
    "text": "is_root(::Logger) returns true if logger.nameis \"root\" or \"\" \n\n\n\n"
},

{
    "location": "api/public.html#Memento.is_set-Tuple{Memento.Logger}",
    "page": "Public",
    "title": "Memento.is_set",
    "category": "Method",
    "text": "is_set(:Logger) returns true or false as to whether the logger is set. (ie: logger.level != \"not_set\") \n\n\n\n"
},

{
    "location": "api/public.html#Memento.notice",
    "page": "Public",
    "title": "Memento.notice",
    "category": "Function",
    "text": "notice(::Logger, ::AbstractString) logs the message at the notice level.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.remove_handler-Tuple{Memento.Logger,Any}",
    "page": "Public",
    "title": "Memento.remove_handler",
    "category": "Method",
    "text": "remove_handler(::Logger, name) removes the Handler with the provided name from the logger.handlers. \n\n\n\n"
},

{
    "location": "api/public.html#Memento.set_level-Tuple{Memento.Logger,AbstractString}",
    "page": "Public",
    "title": "Memento.set_level",
    "category": "Method",
    "text": "set_level(::Logger, ::AbstractString) changes what level this logger should log at.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.set_record-Tuple{Memento.Logger,Type{R<:Memento.Record}}",
    "page": "Public",
    "title": "Memento.set_record",
    "category": "Method",
    "text": "set_record{R<:Record}(::Logger, ::Type{R}) sets the record type for the logger.\n\nArgs:\n\nlogger: the logger to set.\nrec: A Record type to use for logging messages (ie: DefaultRecord).\n\n\n\n"
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
    "category": "Type",
    "text": "DefaultHandler{F<Formatter, O<:IO}(io::O, fmt::F, opts::Dict{Symbol, Any}) creates a DefaultHandler with the specified IO type.\n\nArgs:\n\nio: the IO type\nfmt: the Formatter to use (default to DefaultFormatter())\nopts: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DefaultHandler",
    "page": "Public",
    "title": "Memento.DefaultHandler",
    "category": "Type",
    "text": "The DefaultHandler manages any Formatter, IO and Record.\n\nFields:\n\nfmt: a Formatter for converting Records to Strings\nio: an IO type for printing String to.\nopts: a dictionary of optional arguments such as :is_colorized and :colors   Ex) Dict{Symbol, Any}(           :is_colorized => true,           :opts[:colors] => Dict{AbstractString, Symbol}(               \"debug\" => :blue,               \"info\" => :green,               ...           )       )\n\n\n\n"
},

{
    "location": "api/public.html#Memento.DefaultHandler",
    "page": "Public",
    "title": "Memento.DefaultHandler",
    "category": "Type",
    "text": "DefaultHandler{F<Formatter}(filename::AbstractString, fmt::F, opts::Dict{Symbol, Any}) creates a DefaultHandler with a IO handle to the specified filename.\n\nArgs:\n\nfilename: the filename of a log file to write to\nfmt: the Formatter to use (default to DefaultFormatter())\nopts: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Handler",
    "page": "Public",
    "title": "Memento.Handler",
    "category": "Type",
    "text": "Handlers manage formatting Records and printing the resulting String to an IO type. All Handler subtypes must implement at least 1 log(::Handler, ::Record) method.\n\nNOTE: Handlers can useful if you need to special case logging behaviour based on the Formatter, IO and/or Record types.\n\n\n\n"
},

{
    "location": "api/public.html#Base.log-Tuple{Memento.DefaultHandler{F<:Memento.Formatter,O<:IO},Memento.Record}",
    "page": "Public",
    "title": "Base.log",
    "category": "Method",
    "text": "log{F<:Formatter, O<:IO}(handler::DefaultHandler{F ,O}, rec::Record) logs all records with any Formatter and IO types.\n\n\n\n"
},

{
    "location": "api/public.html#Base.log-Tuple{Memento.DefaultHandler{F<:Memento.Formatter,O<:Memento.Syslog},Memento.Record}",
    "page": "Public",
    "title": "Base.log",
    "category": "Method",
    "text": "logs{F<:Formatter, O<:Syslog}(handler::DefaultHandler{F, O}, rec::Record) logs all records with any Formatter and a Syslog IO type.\n\n\n\n"
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
    "category": "Type",
    "text": "The DefaultFormatter uses a simple format string to build the log message. Fields from the Record to be used should be wrapped curly brackets.\n\nEx) \"[{level} | {name}]: {msg}\" will print message of the form [info | root]: my info message. [warn | root]: my warning message. ...\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Formatter",
    "page": "Public",
    "title": "Memento.Formatter",
    "category": "Type",
    "text": "A Formatter must implement a format(::Formatter, ::Record) method which takes a Record and returns a String representation of the log Record.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.JsonFormatter",
    "page": "Public",
    "title": "Memento.JsonFormatter",
    "category": "Type",
    "text": "JsonFormatter uses the JSON pkg to format the Record into a valid JSON string.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.format-Tuple{Memento.DefaultFormatter,Memento.Record}",
    "page": "Public",
    "title": "Memento.format",
    "category": "Method",
    "text": "format(::DefaultFormatter, ::Record) iteratively replaces entries in the format string with the appropriate fields in the Record\n\n\n\n"
},

{
    "location": "api/public.html#Memento.format-Tuple{Memento.JsonFormatter,Memento.Record}",
    "page": "Public",
    "title": "Memento.format",
    "category": "Method",
    "text": "format(::JsonFormatter, ::Record) converts :date, :lookup and :stacktrace to strings and dicts respectively and call JSON.json() on the resulting dictionary. \n\n\n\n"
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
    "category": "Type",
    "text": "DefaultRecord wraps a Dict{Symbol, Any} which stores basic logging event information.\n\nInfo:\n\ndate: timestamp of log event level: log level levelnum: integer value for log level msg: the log message itself name: the name of the source logger pid: the pid of where the log event occured lookup: the top StackFrame stacktrace: a stacktrace\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Record",
    "page": "Public",
    "title": "Memento.Record",
    "category": "Type",
    "text": "Records are used to store information about a log event including the msg, date, level, stacktrace, etc. Formatters use Records to format log message strings.\n\n\n\n"
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
    "category": "Type",
    "text": "A FileRoller is responsible for managing a rolling log file.\n\nFields:\n\nprefix: filename prefix for the log.\nfolder: directory where the log should be written.\nfile: the current file IO handle\nbyteswritten: keeps track of how many bytes have been written to the current file.\nmax_sz: the maximum number of bytes written to a file before rolling over to another.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.FileRoller-Tuple{Any,Any}",
    "page": "Public",
    "title": "Memento.FileRoller",
    "category": "Method",
    "text": "FileRoller(prefix, dir; max_size=DEFAULT_MAX_FILE_SIZE) creates a rolling log file in the specified directory with the given prefix.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.FileRoller-Tuple{Any}",
    "page": "Public",
    "title": "Memento.FileRoller",
    "category": "Method",
    "text": "FileRoller(prefix; max_size=DEFAULT_MAX_FILE_SIZE) creates a rolling log file in the current working directory with the specified prefix.\n\n\n\n"
},

{
    "location": "api/public.html#Memento.Syslog",
    "page": "Public",
    "title": "Memento.Syslog",
    "category": "Type",
    "text": "Syslog handle writing message to syslog by shelling out to the logger command.\n\nFields:\n\nfacility: The syslog facility to write to (e.g., :local0, :ft, :daemon, etc) (defaults to :local0)\ntag: a tag to use for all message (defaults to \"julia\")\npid: tags julia's pid to messages (defaults to -1 which doesn't include the pid)\n\n\n\n"
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
    "location": "api/private.html#Base.show-Tuple{IO,Memento.Logger}",
    "page": "Private",
    "title": "Base.show",
    "category": "Method",
    "text": "Base.show(::IO, ::Logger) just prints Logger(logger.name) \n\n\n\n"
},

{
    "location": "api/private.html#Memento.get_parent-Tuple{Any}",
    "page": "Private",
    "title": "Memento.get_parent",
    "category": "Method",
    "text": "get_parent(::AbstractString) takes a string representing the name of a logger and returns its parent. If the logger name has no parent then the root logger is returned. Parent loggers are extracted assuming a naming convention of \"foo.bar.baz\", where \"foo.bar.baz\" is the child of \"foo.bar\" which is the child of \"foo\"\n\nArgs:\n\nname: the name of the logger.\n\nReturns the parent logger.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.reset!-Tuple{}",
    "page": "Private",
    "title": "Memento.reset!",
    "category": "Method",
    "text": "reset! removes all registered loggers and reinitializes the root logger without any handlers.\n\n\n\n"
},

{
    "location": "api/private.html#Loggers-1",
    "page": "Private",
    "title": "Loggers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"loggers.jl\"]"
},

{
    "location": "api/private.html#Memento.setup_opts-Tuple{Any}",
    "page": "Private",
    "title": "Memento.setup_opts",
    "category": "Method",
    "text": "setup_opts(opts) sets the default :colors if opts[:is_colorized] == true\n\n\n\n"
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
    "location": "api/private.html#Base.getindex-Tuple{Memento.Record,Any}",
    "page": "Private",
    "title": "Base.getindex",
    "category": "Method",
    "text": "getindex(::Record, key) returns the item from the inner dict\n\n\n\n"
},

{
    "location": "api/private.html#Base.keys-Tuple{Memento.Record}",
    "page": "Private",
    "title": "Base.keys",
    "category": "Method",
    "text": "keys(::Record) returns all keys in the inner dict\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getdict-Tuple{Memento.Record}",
    "page": "Private",
    "title": "Memento.getdict",
    "category": "Method",
    "text": "getdict(::Record) returns the inner dict of the record \n\n\n\n"
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
    "category": "Method",
    "text": "flush(::FileRoller) flushes the current open file.\n\n\n\n"
},

{
    "location": "api/private.html#Base.flush-Tuple{Memento.Syslog}",
    "page": "Private",
    "title": "Base.flush",
    "category": "Method",
    "text": "flush(::Syslog) is defined just in case somebody decides to call flush, which is unnecessary.\n\n\n\n"
},

{
    "location": "api/private.html#Base.println-Tuple{Memento.FileRoller,AbstractString}",
    "page": "Private",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::FileRoller, ::AbstractString) writes the string to a file and creates a new file if we've reached the max file size.\n\n\n\n"
},

{
    "location": "api/private.html#Base.println-Tuple{Memento.Syslog,AbstractString,AbstractString}",
    "page": "Private",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::Syslog, ::AbstractString, ::AbstractString) converts the first AbstractString to a Symbol and call println(::Syslog, ::Symbol, ::AbstractString)\n\n\n\n"
},

{
    "location": "api/private.html#Base.println-Tuple{Memento.Syslog,Symbol,AbstractString}",
    "page": "Private",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::Syslog, ::Symbol, ::AbstractString) writes the AbstractString to logger with the Symbol representing the syslog level.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getfile-Tuple{AbstractString,AbstractString}",
    "page": "Private",
    "title": "Memento.getfile",
    "category": "Method",
    "text": "getfile(folder::AbstractString, prefix::AbstractString) grabs the next log file.\n\n\n\n"
},

{
    "location": "api/private.html#Memento.getsuffix-Tuple{Integer}",
    "page": "Private",
    "title": "Memento.getsuffix",
    "category": "Method",
    "text": "getsuffix(::Integer) formats the nth file suffix.\n\n\n\n"
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
    "text": "To start hacking code or writing docs, simply:julia> Pkg.add(\"Memento\"); Pkg.checkout(\"Memento\")\nMake your changes.\nTest your changes with julia --compilecache=no -e 'Pkg.test(\"Memento\"; coverage=true)'\nCheck that your changes haven't reduced the test coverage. From the root Memento package folder run julia -e 'using Coverage; Coverage.get_summary(process_folder())'.\nMake a pull request to Memento and share your changes with the rest of the community."
},

{
    "location": "contributing.html#Bugs,-features,-and-requests-1",
    "page": "Contributing",
    "title": "Bugs, features, and requests",
    "category": "section",
    "text": "Feel free to file issues when you encounter bugs, think of interesting features you'd like to see, or when there are important changes not yet included in a release and you'd like us to tag a new version."
},

{
    "location": "contributing.html#Submitting-your-contributions-1",
    "page": "Contributing",
    "title": "Submitting your contributions",
    "category": "section",
    "text": "By contributing code to Memento, you are agreeing to release your work under the MIT License.We love contributions in the form of pull requests! Assuming you've been working in a repo checked out as above, this should be easy to do. For a detailed walkthrough, check here, otherwise:Navigate to Memento.jl and create a fork.\ngit remote add origin https://github.com/user/Memento.jl.git\ngit push origin master\nSubmit your changes as a pull request!For pull requests to be accepted we require that the changes:Pass on travis and appveyor\nMaintain 100% test coverage"
},

]}
