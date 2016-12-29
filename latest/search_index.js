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
    "text": "(Image: quickstart)"
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
    "text": "There are five main components of Memento.jl that you can manipulate:"
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
    "text": "Formatters describe how to take a Record and convert it into properly formatted string. Currently, there are two types of Formatters.DefaultFormatter - use a simple template string format to map keys in the Record to places in the resulting string.julia> DefaultFormatter(\"[{date} | {level} | {name}]: {msg}\")JsonFormatter - builds an appropriate formatted Dict from the Record in order to use JSON.json(dict) to produce the resulting string."
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
    "text": "Records describe a set of key value pairs that should be available to a  Formatter on every log message. While the DefaultRecord in Memento provides many of the keys and values need for most logging applications, you may need to implement your own Record type.Internal DefaultRecord Dict:Dict(\n    :date => round(now(), Base.Dates.Second),\n    :level => args[:level],\n    :levelnum => args[:levelnum],\n    :msg => args[:msg],\n    :name => args[:name],\n    :pid => myid(),\n    :lookup => isempty(trace) ? nothing : first(trace),\n    :stacktrace => trace,\n)"
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
    "location": "faq.html#",
    "page": "FAQ",
    "title": "FAQ",
    "category": "page",
    "text": ""
},

{
    "location": "faq.html#FAQ-1",
    "page": "FAQ",
    "title": "FAQ",
    "category": "section",
    "text": ""
},

{
    "location": "faq.html#Table-of-Contents-1",
    "page": "FAQ",
    "title": "Table of Contents",
    "category": "section",
    "text": "Why another logging library for julia?\nHow do I set logging levels?\nHow do I change the colors?"
},

{
    "location": "faq.html#Why-another-logging-library-for-Julia?-1",
    "page": "FAQ",
    "title": "Why another logging library for Julia?",
    "category": "section",
    "text": "_...or why did you fork Lumberjack.jl?_The short answer is that none of the existing logging libraries quite fit our requirements. The summary table provided below shows that all of the existing libraries are missing more than 1 requirement. Our initial goal was to add more tests, hierarchical logging and some API changes to Lumberjack as it seemed to have the best balance of features and test coverage. In the end, our changes diverged enough from Lumberjack that it made more sense to fork the project.Library Hierarchical Custom Formatting Custom IO Types Syslog Color Coverage Version\nLogging.jl Kinda No Yes Yes Yes 61% 0.3.1\nLumberjack.jl No Kinda Yes Yes Yes 76% 2.1.0\nMiniLogger.jl Yes No Yes No No 87% 0.0.2\nMemento.jl Yes Yes Yes Yes Yes 100% N/AYou can see from the table that Memento covers all of our logging requirements and has significantly higher test coverage."
},

{
    "location": "faq.html#How-do-I-set-logging-levels?-1",
    "page": "FAQ",
    "title": "How do I set logging levels?",
    "category": "section",
    "text": "You can globally set the minimum logging level with basic_config.julia>basic_config(\"debug\")Will log all messages for all loggers at or above \"debug\".julia>basic_config(\"warn\")Will only log message at or above the \"warn\" level.We can also set the logging level for specific loggers or collections of loggers if we explicitly set the level on an existing logger.julia>set_level(get_logger(\"Main\"), \"info\")Will only set the logging level to \"info\" for the \"Main\" logger and any future children of the \"Main\" logger."
},

{
    "location": "faq.html#How-do-I-change-the-colors?-1",
    "page": "FAQ",
    "title": "How do I change the colors?",
    "category": "section",
    "text": "Colors can be enabled/disabled and set using via the is_colorized and colors options to the DefaultHandler.julia> add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(:is_colorized => true)),\n    \"console\"\n)Will create a DefaultHandler with colorizationBy default the following colors are used:Dict{AbstractString, Symbol}(\n    \"debug\" => :blue,\n    \"info\" => :green,\n    \"notice\" => :cyan,\n    \"warn\" => :magenta,\n    \"error\" => :red,\n    \"critical\" => :yellow,\n    \"alert\" => :white,\n    \"emergency\" => :black,\n)However, you can specify custom colors/log levels like so:add_handler(logger, DefaultHandler(\n    STDOUT, DefaultFormatter(),\n    Dict{Symbol, Any}(\n        :colors => Dict{AbstractString, Symbol}(\n            \"debug\" => :black,\n            \"info\" => :blue,\n            \"warn\" => :yellow,\n            \"error\" => :red,\n            \"crazy\" => :green\n        )\n    ),\n    \"console\"\n)You can also globally disable colorization when running basic_configjulia> basic_config(\"info\"; fmt=\"[{date} | {level} | {name}]: {msg}\", colorized=false)"
},

{
    "location": "api.html#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api.html#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#Public-1",
    "page": "API",
    "title": "Public",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#Memento.Logger",
    "page": "API",
    "title": "Memento.Logger",
    "category": "Type",
    "text": "A Logger is responsible for converting msg strings into Records which are then passed to each handler. By default loggers propagate their message to their parent loggers.\n\nFields:\n\nname: is the name of the logger (required).\nhandlers: is a collection of Handlers (defaults to empty Dict).\nlevel: the current minimum logging level for the logger to log message to handlers (defaults to \"not_set\").\nlevels: a mapping of available logging levels to their relative priority (represented as integer values) (defaults to using Memento._log_levels)\nrecord: the Record type that should be produced by this logger (defaults to DefaultRecord).\npropagate: whether or not this logger should propagate its message to its parent (defaults to true).\n\n\n\n"
},

{
    "location": "api.html#Base.error",
    "page": "API",
    "title": "Base.error",
    "category": "Function",
    "text": "error(::Logger, ::AbstractString) logs the message at the error level and throws an ErrorException with that message error(::Logger, ::Exception) calls error(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api.html#Base.info",
    "page": "API",
    "title": "Base.info",
    "category": "Function",
    "text": "info(::Logger, ::AbstractString) logs the message at the info level.\n\n\n\n"
},

{
    "location": "api.html#Base.log-Tuple{Memento.Logger,AbstractString,AbstractString}",
    "page": "API",
    "title": "Base.log",
    "category": "Method",
    "text": "log(::Logger, ::AbstractString, ::AbstractString) creates a Dict with the logger name, level, levelnum and message and calls the other log method (which may recursively call itself on parent loggers with the created Dict).\n\nArgs:\n\nlogger: the logger to log to.\nlevel: the log level as a String\nmsg: the msg to log as a String\n\n\n\n"
},

{
    "location": "api.html#Base.log-Tuple{Memento.Logger,Dict{Symbol,Any}}",
    "page": "API",
    "title": "Base.log",
    "category": "Method",
    "text": "log(::Logger, ::Dict{Symbol, Any}) logs logger.record(args) to its handlers if it has the appropriate args[:level] and args[:level] is above the priority of logger.level. If this logger is not the root logger and logger.propagate is true then the parent logger is called.\n\nArgs:\n\nlogger: the logger to log args to.\nargs: a dict of msg fields and values that should be passed to logger.record.\n\n\n\n"
},

{
    "location": "api.html#Base.warn",
    "page": "API",
    "title": "Base.warn",
    "category": "Function",
    "text": "warn(::Logger, ::AbstractString) logs the message at the warn level.\n\n\n\n"
},

{
    "location": "api.html#Base.warn-Tuple{Memento.Logger,Exception}",
    "page": "API",
    "title": "Base.warn",
    "category": "Method",
    "text": "warn(::Logger, ::Exception) takes an exception and logs it. \n\n\n\n"
},

{
    "location": "api.html#Memento.add_handler",
    "page": "API",
    "title": "Memento.add_handler",
    "category": "Function",
    "text": "add_handler(::Logger, ::Handler, name) adds a new handler to logger.handlers. If a name is not provided a random one will be generated.\n\nArgs:\n\nlogger: the logger to use.\nhandler: the handler to add.\nname: a name to identify the handler.\n\n\n\n"
},

{
    "location": "api.html#Memento.add_level-Tuple{Memento.Logger,AbstractString,Int64}",
    "page": "API",
    "title": "Memento.add_level",
    "category": "Method",
    "text": "add_level(::Logger, ::AbstractString, ::Int) adds a new level::String and priority::Int to the logger.levels\n\n\n\n"
},

{
    "location": "api.html#Memento.alert",
    "page": "API",
    "title": "Memento.alert",
    "category": "Function",
    "text": "alert(::Logger, ::AbstractString) logs the message at the alert level and throws an ErrorException with that message alert(::Logger, ::Exception) calls alert(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api.html#Memento.basic_config-Tuple{AbstractString}",
    "page": "API",
    "title": "Memento.basic_config",
    "category": "Method",
    "text": "basic_config(::AbstractString; ::AbstractString, ::Dict{AbstractString, Int}, colorized::Bool) sets the Memento._log_levels, creates a default root logger with a DefaultHandler that prints to STDOUT.\n\nArgs:\n\nlevel: the minimum logging level to log message to the root logger (required).\nfmt: a format string to pass to the DefaultFormatter which describes how to log messages (defaults to Memento.DEFAULT_FMT_STRING)\nlevels: the default logging levels to use (defaults to Memento._log_levels).\ncolorized: whether or not the message to STDOUT should be colorized.\n\nReturns the root logger.\n\n\n\n"
},

{
    "location": "api.html#Memento.critical",
    "page": "API",
    "title": "Memento.critical",
    "category": "Function",
    "text": "critical(::Logger, ::AbstractString) logs the message at the critical level and throws an ErrorException with that message critical(::Logger, ::Exception) calls critical(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api.html#Memento.debug",
    "page": "API",
    "title": "Memento.debug",
    "category": "Function",
    "text": "debug(::Logger, ::AbstractString) logs the message at the debug level.\n\n\n\n"
},

{
    "location": "api.html#Memento.emergency",
    "page": "API",
    "title": "Memento.emergency",
    "category": "Function",
    "text": "emergency(::Logger, ::AbstractString) logs the message at the emergency level and throws an ErrorException with that message emergency(::Logger, ::Exception) calls emergency(logger, msg) with the contents of the Exception.\n\n\n\n"
},

{
    "location": "api.html#Memento.get_handlers-Tuple{Memento.Logger}",
    "page": "API",
    "title": "Memento.get_handlers",
    "category": "Method",
    "text": "get_handlers(::Logger) returns logger.handlers\n\n\n\n"
},

{
    "location": "api.html#Memento.get_logger",
    "page": "API",
    "title": "Memento.get_logger",
    "category": "Function",
    "text": "get_logger(::AbstractString) returns the appropriate logger. If the logger or its parents do not exist then they are initialized with no handlers and not set.\n\nArgs: the name of the logger (defaults to \"root\")\n\nReturns the logger.\n\n\n\n"
},

{
    "location": "api.html#Memento.get_logger-Tuple{Module}",
    "page": "API",
    "title": "Memento.get_logger",
    "category": "Method",
    "text": "get_logger(name::Module) converts the Module to a String and calls get_logger(name::String).\n\nArgs: name of the logger\n\nReturns the logger.\n\n\n\n"
},

{
    "location": "api.html#Memento.is_root-Tuple{Memento.Logger}",
    "page": "API",
    "title": "Memento.is_root",
    "category": "Method",
    "text": "is_root(::Logger) returns true if logger.nameis \"root\" or \"\" \n\n\n\n"
},

{
    "location": "api.html#Memento.is_set-Tuple{Memento.Logger}",
    "page": "API",
    "title": "Memento.is_set",
    "category": "Method",
    "text": "is_set(:Logger) returns true or false as to whether the logger is set. (ie: logger.level != \"not_set\") \n\n\n\n"
},

{
    "location": "api.html#Memento.notice",
    "page": "API",
    "title": "Memento.notice",
    "category": "Function",
    "text": "notice(::Logger, ::AbstractString) logs the message at the notice level.\n\n\n\n"
},

{
    "location": "api.html#Memento.remove_handler-Tuple{Memento.Logger,Any}",
    "page": "API",
    "title": "Memento.remove_handler",
    "category": "Method",
    "text": "remove_handler(::Logger, name) removes the Handler with the provided name from the logger.handlers. \n\n\n\n"
},

{
    "location": "api.html#Memento.set_level-Tuple{Memento.Logger,AbstractString}",
    "page": "API",
    "title": "Memento.set_level",
    "category": "Method",
    "text": "set_level(::Logger, ::AbstractString) changes what level this logger should log at.\n\n\n\n"
},

{
    "location": "api.html#Memento.set_record-Tuple{Memento.Logger,Type{R<:Memento.Record}}",
    "page": "API",
    "title": "Memento.set_record",
    "category": "Method",
    "text": "set_record{R<:Record}(::Logger, ::Type{R}) sets the record type for the logger.\n\nArgs:\n\nlogger: the logger to set.\nrec: A Record type to use for logging messages (ie: DefaultRecord).\n\n\n\n"
},

{
    "location": "api.html#Loggers-1",
    "page": "API",
    "title": "Loggers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"loggers.jl\"]"
},

{
    "location": "api.html#Memento.DefaultHandler",
    "page": "API",
    "title": "Memento.DefaultHandler",
    "category": "Type",
    "text": "DefaultHandler{F<Formatter}(filename::AbstractString, fmt::F, opts::Dict{Symbol, Any}) creates a DefaultHandler with a IO handle to the specified filename.\n\nArgs:\n\nfilename: the filename of a log file to write to\nfmt: the Formatter to use (default to DefaultFormatter())\nopts: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api.html#Memento.DefaultHandler",
    "page": "API",
    "title": "Memento.DefaultHandler",
    "category": "Type",
    "text": "The DefaultHandler manages any Formatter, IO and Record.\n\nFields:\n\nfmt: a Formatter for converting Records to Strings\nio: an IO type for printing String to.\nopts: a dictionary of optional arguments such as :is_colorized and :colors   Ex) Dict{Symbol, Any}(           :is_colorized => true,           :opts[:colors] => Dict{AbstractString, Symbol}(               \"debug\" => :blue,               \"info\" => :green,               ...           )       )\n\n\n\n"
},

{
    "location": "api.html#Memento.DefaultHandler",
    "page": "API",
    "title": "Memento.DefaultHandler",
    "category": "Type",
    "text": "DefaultHandler{F<Formatter, O<:IO}(io::O, fmt::F, opts::Dict{Symbol, Any}) creates a DefaultHandler with the specified IO type.\n\nArgs:\n\nio: the IO type\nfmt: the Formatter to use (default to DefaultFormatter())\nopts: the optional arguments (defaults to Dict{Symbol, Any}())\n\n\n\n"
},

{
    "location": "api.html#Memento.Handler",
    "page": "API",
    "title": "Memento.Handler",
    "category": "Type",
    "text": "Handlers manage formatting Records and printing the resulting String to an IO type. All Handler subtypes must implement at least 1 log(::Handler, ::Record) method.\n\nNOTE: Handlers can useful if you need to special case logging behaviour based on the Formatter, IO and/or Record types.\n\n\n\n"
},

{
    "location": "api.html#Base.log-Tuple{Memento.DefaultHandler{F<:Memento.Formatter,O<:IO},Memento.Record}",
    "page": "API",
    "title": "Base.log",
    "category": "Method",
    "text": "log{F<:Formatter, O<:IO}(handler::DefaultHandler{F ,O}, rec::Record) logs all records with any Formatter and IO types.\n\n\n\n"
},

{
    "location": "api.html#Base.log-Tuple{Memento.DefaultHandler{F<:Memento.Formatter,O<:Memento.Syslog},Memento.Record}",
    "page": "API",
    "title": "Base.log",
    "category": "Method",
    "text": "logs{F<:Formatter, O<:Syslog}(handler::DefaultHandler{F, O}, rec::Record) logs all records with any Formatter and a Syslog IO type.\n\n\n\n"
},

{
    "location": "api.html#Handlers-1",
    "page": "API",
    "title": "Handlers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"handlers.jl\"]"
},

{
    "location": "api.html#Memento.DefaultFormatter",
    "page": "API",
    "title": "Memento.DefaultFormatter",
    "category": "Type",
    "text": "The DefaultFormatter uses a simple format string to build the log message. Fields from the Record to be used should be wrapped curly brackets.\n\nEx) \"[{level} | {name}]: {msg}\" will print message of the form [info | root]: my info message. [warn | root]: my warning message. ...\n\n\n\n"
},

{
    "location": "api.html#Memento.Formatter",
    "page": "API",
    "title": "Memento.Formatter",
    "category": "Type",
    "text": "A Formatter must implement a format(::Formatter, ::Record) method which takes a Record and returns a String representation of the log Record.\n\n\n\n"
},

{
    "location": "api.html#Memento.JsonFormatter",
    "page": "API",
    "title": "Memento.JsonFormatter",
    "category": "Type",
    "text": "JsonFormatter uses the JSON pkg to format the Record into a valid JSON string.\n\n\n\n"
},

{
    "location": "api.html#Memento.format-Tuple{Memento.DefaultFormatter,Memento.Record}",
    "page": "API",
    "title": "Memento.format",
    "category": "Method",
    "text": "format(::DefaultFormatter, ::Record) iteratively replaces entries in the format string with the appropriate fields in the Record\n\n\n\n"
},

{
    "location": "api.html#Memento.format-Tuple{Memento.JsonFormatter,Memento.Record}",
    "page": "API",
    "title": "Memento.format",
    "category": "Method",
    "text": "format(::JsonFormatter, ::Record) converts :date, :lookup and :stacktrace to strings and dicts respectively and call JSON.json() on the resulting dictionary. \n\n\n\n"
},

{
    "location": "api.html#Formatters-1",
    "page": "API",
    "title": "Formatters",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"formatters.jl\"]"
},

{
    "location": "api.html#Memento.DefaultRecord",
    "page": "API",
    "title": "Memento.DefaultRecord",
    "category": "Type",
    "text": "DefaultRecord wraps a Dict{Symbol, Any} which stores basic logging event information.\n\nInfo:\n\ndate: timestamp of log event level: log level levelnum: integer value for log level msg: the log message itself name: the name of the source logger pid: the pid of where the log event occured lookup: the top StackFrame stacktrace: a stacktrace\n\n\n\n"
},

{
    "location": "api.html#Memento.Record",
    "page": "API",
    "title": "Memento.Record",
    "category": "Type",
    "text": "Records are used to store information about a log event including the msg, date, level, stacktrace, etc. Formatters use Records to format log message strings.\n\n\n\n"
},

{
    "location": "api.html#Records-1",
    "page": "API",
    "title": "Records",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"records.jl\"]"
},

{
    "location": "api.html#Memento.FileRoller",
    "page": "API",
    "title": "Memento.FileRoller",
    "category": "Type",
    "text": "A FileRoller is responsible for managing a rolling log file.\n\nFields:\n\nprefix: filename prefix for the log.\nfolder: directory where the log should be written.\nfile: the current file IO handle\nbyteswritten: keeps track of how many bytes have been written to the current file.\nmax_sz: the maximum number of bytes written to a file before rolling over to another.\n\n\n\n"
},

{
    "location": "api.html#Memento.FileRoller-Tuple{Any,Any}",
    "page": "API",
    "title": "Memento.FileRoller",
    "category": "Method",
    "text": "FileRoller(prefix, dir; max_size=DEFAULT_MAX_FILE_SIZE) creates a rolling log file in the specified directory with the given prefix.\n\n\n\n"
},

{
    "location": "api.html#Memento.FileRoller-Tuple{Any}",
    "page": "API",
    "title": "Memento.FileRoller",
    "category": "Method",
    "text": "FileRoller(prefix; max_size=DEFAULT_MAX_FILE_SIZE) creates a rolling log file in the current working directory with the specified prefix.\n\n\n\n"
},

{
    "location": "api.html#Memento.Syslog",
    "page": "API",
    "title": "Memento.Syslog",
    "category": "Type",
    "text": "Syslog handle writing message to syslog by shelling out to the logger command.\n\nFields:\n\nfacility: The syslog facility to write to (e.g., :local0, :ft, :daemon, etc) (defaults to :local0)\ntag: a tag to use for all message (defaults to \"julia\")\npid: tags julia's pid to messages (defaults to -1 which doesn't include the pid)\n\n\n\n"
},

{
    "location": "api.html#IO-1",
    "page": "API",
    "title": "IO",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = false\nPages = [\"io.jl\"]"
},

{
    "location": "api.html#Private-1",
    "page": "API",
    "title": "Private",
    "category": "section",
    "text": ""
},

{
    "location": "api.html#Base.show-Tuple{IO,Memento.Logger}",
    "page": "API",
    "title": "Base.show",
    "category": "Method",
    "text": "Base.show(::IO, ::Logger) just prints Logger(logger.name) \n\n\n\n"
},

{
    "location": "api.html#Memento.get_parent-Tuple{Any}",
    "page": "API",
    "title": "Memento.get_parent",
    "category": "Method",
    "text": "get_parent(::AbstractString) takes a string representing the name of a logger and returns its parent. If the logger name has no parent then the root logger is returned. Parent loggers are extracted assuming a naming convention of \"foo.bar.baz\", where \"foo.bar.baz\" is the child of \"foo.bar\" which is the child of \"foo\"\n\nArgs:\n\nname: the name of the logger.\n\nReturns the parent logger.\n\n\n\n"
},

{
    "location": "api.html#Memento.reset!-Tuple{}",
    "page": "API",
    "title": "Memento.reset!",
    "category": "Method",
    "text": "reset! removes all registered loggers and reinitializes the root logger without any handlers.\n\n\n\n"
},

{
    "location": "api.html#Loggers-2",
    "page": "API",
    "title": "Loggers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"loggers.jl\"]"
},

{
    "location": "api.html#Memento.setup_opts-Tuple{Any}",
    "page": "API",
    "title": "Memento.setup_opts",
    "category": "Method",
    "text": "setup_opts(opts) sets the default :colors if opts[:is_colorized] == true\n\n\n\n"
},

{
    "location": "api.html#Handlers-2",
    "page": "API",
    "title": "Handlers",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"handlers.jl\"]"
},

{
    "location": "api.html#Formatters-2",
    "page": "API",
    "title": "Formatters",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"formatters.jl\"]"
},

{
    "location": "api.html#Base.getindex-Tuple{Memento.Record,Any}",
    "page": "API",
    "title": "Base.getindex",
    "category": "Method",
    "text": "getindex(::Record, key) returns the item from the inner dict\n\n\n\n"
},

{
    "location": "api.html#Base.keys-Tuple{Memento.Record}",
    "page": "API",
    "title": "Base.keys",
    "category": "Method",
    "text": "keys(::Record) returns all keys in the inner dict\n\n\n\n"
},

{
    "location": "api.html#Memento.getdict-Tuple{Memento.Record}",
    "page": "API",
    "title": "Memento.getdict",
    "category": "Method",
    "text": "getdict(::Record) returns the inner dict of the record \n\n\n\n"
},

{
    "location": "api.html#Records-2",
    "page": "API",
    "title": "Records",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"records.jl\"]"
},

{
    "location": "api.html#Base.flush-Tuple{Memento.FileRoller}",
    "page": "API",
    "title": "Base.flush",
    "category": "Method",
    "text": "flush(::FileRoller) flushes the current open file.\n\n\n\n"
},

{
    "location": "api.html#Base.flush-Tuple{Memento.Syslog}",
    "page": "API",
    "title": "Base.flush",
    "category": "Method",
    "text": "flush(::Syslog) is defined just in case somebody decides to call flush, which is unnecessary.\n\n\n\n"
},

{
    "location": "api.html#Base.println-Tuple{Memento.FileRoller,AbstractString}",
    "page": "API",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::FileRoller, ::AbstractString) writes the string to a file and creates a new file if we've reached the max file size.\n\n\n\n"
},

{
    "location": "api.html#Base.println-Tuple{Memento.Syslog,AbstractString,AbstractString}",
    "page": "API",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::Syslog, ::AbstractString, ::AbstractString) converts the first AbstractString to a Symbol and call println(::Syslog, ::Symbol, ::AbstractString)\n\n\n\n"
},

{
    "location": "api.html#Base.println-Tuple{Memento.Syslog,Symbol,AbstractString}",
    "page": "API",
    "title": "Base.println",
    "category": "Method",
    "text": "println(::Syslog, ::Symbol, ::AbstractString) writes the AbstractString to logger with the Symbol representing the syslog level.\n\n\n\n"
},

{
    "location": "api.html#Memento.getfile-Tuple{AbstractString,AbstractString}",
    "page": "API",
    "title": "Memento.getfile",
    "category": "Method",
    "text": "getfile(folder::AbstractString, prefix::AbstractString) grabs the next log file.\n\n\n\n"
},

{
    "location": "api.html#Memento.getsuffix-Tuple{Integer}",
    "page": "API",
    "title": "Memento.getsuffix",
    "category": "Method",
    "text": "getsuffix(::Integer) formats the nth file suffix.\n\n\n\n"
},

{
    "location": "api.html#IO-2",
    "page": "API",
    "title": "IO",
    "category": "section",
    "text": "Modules = [Memento]\nPrivate = true\nPages = [\"io.jl\"]"
},

]}
