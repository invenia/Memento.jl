using JSON

"""
    Formatter

A `Formatter` must implement a `format(::Formatter, ::Record)` method
which takes a `Record` and returns a `String` representation of the
log `Record`.
"""
abstract Formatter

const DEFAULT_FMT_STRING = "[{level} | {name}]: {msg}"

"""
    DefaultFormatter

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
    tokens::Vector{Pair{Symbol, Bool}}

    function DefaultFormatter(fmt_str::AbstractString=DEFAULT_FMT_STRING)
        #r"(?<={).+?(?=})
        tokens = map(eachmatch(r"({.+?})|(.+?)", fmt_str)) do m
            #println(dump(m))
            if m.captures[1] != nothing
                return Symbol(strip(m.match, ('{', '}'))) => true
            else
                return Symbol(m.match) => false
            end
        end

        new(fmt_str, tokens)
    end
end

"""
    format(::DefaultFormatter, ::Record) -> String

Iteratively replaces entries in the
format string with the appropriate fields in the `Record`
"""
function format(fmt::DefaultFormatter, rec::Record)
    result = fmt.fmt_str

    parts = map(fmt.tokens) do token
        content = token.first
        value = content

        if token.second
            tmp_val = rec[content]

            if content === :lookup
                name, file, line = if isa(tmp_val, StackFrame)
                    # lookup is a StackFrame
                    tmp_val.func, tmp_val.file, tmp_val.line
                else
                    "<nothing>", "", -1
                end

                value = "$(name)@$(basename(string(file))):$(line)"
            elseif content === :stacktrace
                # stacktrace is a vector of StackFrames
                str_frames = map(tmp_val) do frame
                    string(frame.func, "@", basename(string(frame.file)), ":", frame.line)
                end

                value = string(" stack:[", join(str_frames, ", "), "]")
            else
                value = tmp_val
            end
        end

        return value
    end

    return string(parts...)
end

"""
    JsonFormatter

Uses the JSON pkg to format the `Record` into a valid
JSON string.
"""
type JsonFormatter <: Formatter
    aliases::Nullable{Dict{Symbol, Symbol}}

    JsonFormatter() = new(Nullable())
    JsonFormatter(aliases::Dict{Symbol, Symbol}) = new(Nullable(aliases))
end

"""
    format(::JsonFormatter, ::Record) -> String

Converts :date, :lookup and :stacktrace to strings
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

        if key === :date
            value = string(tmp_val)
        elseif key === :lookup
            value = if isa(tmp_val, StackFrame)
                Dict(
                    :name => tmp_val.func,
                    :file => basename(string(tmp_val.file)),
                    :line => tmp_val.line
                )
            else
                Dict(
                    :name => "<nothing>",
                    :file => "",
                    :line => -1
                )
            end
        elseif key === :stacktrace
            value = map(
                frame -> Dict(
                    :name => frame.func,
                    :file => basename(string(frame.file)),
                    :line => frame.line
                ),
                tmp_val
            )
        else
            value = tmp_val
        end

        dict[alias] = value
    end

    return json(dict)
end
