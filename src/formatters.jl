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
        tmp_val = rec[field]

        value = if field === :lookup
            # lookup is a StackFrame
            name, file, line = tmp_val.func, tmp_val.file, tmp_val.line
            "$(name)@$(basename(string(file))):$(line)"
        elseif field === :stacktrace
            # stacktrace is a vector of StackFrames
            str_frames = map(tmp_val) do frame
                string(frame.func, "@", basename(string(frame.file)), ":", frame.line)
            end

            string(" stack:[", join(str_frames, ", "), "]")
        else
            tmp_val
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
        names = fieldnames(rec)
        Dict(zip(names, names))
    else
        get(fmt.aliases)
    end

    dict = Dict{Symbol, Any}()

    for (alias, key) in aliases
        tmp_val = rec[key]

        value = if key === :date
            string(tmp_val)
        elseif key === :lookup
            Dict(
                :name => tmp_val.func,
                :file => basename(string(tmp_val.file)),
                :line => tmp_val.line
            )
        elseif key === :stacktrace
            map(
                frame -> Dict(
                    :name => frame.func,
                    :file => basename(string(frame.file)),
                    :line => frame.line
                ),
                tmp_val
            )
        else
            tmp_val
        end

        dict[alias] = value
    end

    return json(dict)
end
