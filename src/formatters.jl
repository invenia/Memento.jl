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
    tokens::Vector{SubString{String}}

    function DefaultFormatter(fmt_str::AbstractString=DEFAULT_FMT_STRING)
        new(fmt_str, matchall(r"(?<={).+?(?=})", fmt_str))
    end
end

"""
`format(::DefaultFormatter, ::Record)` iteratively replaces entries in the
format string with the appropriate fields in the `Record`
"""
function format(fmt::DefaultFormatter, rec::Record)
    result = fmt.fmt_str

    for token in fmt.tokens
        field = Symbol(token)

        value = if field === :lookup
            # lookup is a StackFrame
            name, file, line = dict[field].func, dict[field].file, dict[field].line
            "$(name)@$(basename(string(file))):$(line)"
        elseif field === :stacktrace
            # stacktrace is a vector of StackFrames
            string(
                " stack:[",
                join(map(f->"$(f.func)@$(basename(string(f.file))):$(f.line)", dict[field]), ", "),
                "]"
            )
        else
            rec[field]
        end

        result = replace(result, "{$token}", value)
    end

    return result
end

"""
`JsonFormatter` uses the JSON pkg to format the `Record` into a valid
JSON string.
"""
type JsonFormatter <: Formatter
    aliases::Nullable{Dict{Symbol, Symbol}}

    JsonFormatter() = new(Nullable())
    JsonFormatter(aliases::Dict{Symbol, Symbol}) = new(Nullable(aliases))
end

"""
`format(::JsonFormatter, ::Record)` converts :date, :lookup and :stacktrace to strings
and dicts respectively and call `JSON.json()` on the resulting dictionary.
"""
function format(fmt::JsonFormatter, rec::Record)
    aliases = if isnull(fmt.aliases)
        Dict(zip(keys(rec), keys(rec)))
    else
        get(fmt.aliases)
    end

    dict = Dict{Symbol, Any}()

    for (alias, key) in aliases
        value = if key === :date
            string(rec[:date])
        elseif key === :lookup
            Dict(
                :name => rec[:lookup].func,
                :file => basename(string(rec[:lookup].file)),
                :line => rec[:lookup].line
            )
        elseif key === :stacktrace
            map(
                f -> Dict(
                    :name => f.func,
                    :file => basename(string(f.file)),
                    :line => f.line
                ),
                rec[:stacktrace]
            )
        else
            rec[key]
        end

        dict[alias] = value
    end

    return json(dict)
end
