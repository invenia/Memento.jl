using JSON

"""
A `Formatter` must implement a `format(::Formatter, ::Record)` method
which takes a `Record` and returns a `String` representation of the
log `Record`.
"""
abstract Formatter

const DEFAULT_FMT_STRING = "[{level} | {name}]: {msg}"

"""
The `DefaultFormatter` uses a simple format string to build
the log message. Fields from the `Record` to be used should be
wrapped curly brackets.

Ex) "[{level} | {name}]: {msg}" will print message of the form
[info | root]: my info message.
[warn | root]: my warning message.
...
"""
immutable DefaultFormatter <: Formatter
    fmt_str::AbstractString

    function DefaultFormatter(fmt_str::AbstractString=DEFAULT_FMT_STRING)
        new(fmt_str)
    end
end

"""
`format(::DefaultFormatter, ::Record)` iteratively replaces entries in the
format string with the appropriate fields in the `Record`
"""
function format(fmt::DefaultFormatter, rec::Record)
    dict = Dict(rec)
    result = fmt.fmt_str

    for field in keys(dict)
        if field === :lookup
            # lookup is a StackFrame
            name, file, line = dict[field].func, dict[field].file, dict[field].line
            dict[field] = "$(name)@$(basename(string(file))):$(line)"
        elseif field === :stacktrace
            # stacktrace is a vector of StackFrames
            dict[field] = string(
                " stack:[",
                join(map(f->"$(f.func)@$(basename(string(f.file))):$(f.line)", dict[field]), ", "),
                "]"
            )
        end

        result = replace(result, "{$field}", dict[field])
    end

    return result
end

"""
`JsonFormatter` uses the JSON pkg to format the `Record` into a valid
JSON string.
"""
type JsonFormatter <: Formatter end

"""
`format(::JsonFormatter, ::Record)` converts :date, :lookup and :stacktrace to strings
and dicts respectively and call `JSON.json()` on the resulting dictionary.
"""
function format(fmt::JsonFormatter, rec::Record)
    dict = Dict(rec)

    if haskey(dict, :date)
        dict[:date] = string(dict[:date])
    end

    if haskey(dict, :lookup)
        dict[:lookup] = Dict(
            :name => dict[:lookup].func,
            :file => basename(string(dict[:lookup].file)),
            :line => dict[:lookup].line
        )
    end

    if haskey(dict, :stacktrace)
        dict[:stacktrace] = map(
            f -> Dict(
                :name => f.func,
                :file => basename(string(f.file)),
                :line => f.line
            ),
            dict[:stacktrace]
        )
    end

    return json(dict)
end
