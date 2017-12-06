"""
    Formatter

A `Formatter` must implement a `format(::Formatter, ::Record)` method
which takes a `Record` and returns a `String` representation of the
log `Record`.
"""
abstract type Formatter end

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
struct DefaultFormatter <: Formatter
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
    DictFormatter([aliases])

Formats the record to Dict that is amenable to serialization formats such as JSON.
The `aliases` argument is a `Dict{Symbol, Symbol}` where they keys represented aliases and
values represent existing record attributes to include in the dictionary.
If no `aliases` argument is provided then all fields in the record type will be used.
"""
struct DictFormatter <: Formatter
    aliases::Nullable{Dict{Symbol, Symbol}}

    DictFormatter() = new(Nullable())
    DictFormatter(aliases::Dict{Symbol, Symbol}) = new(Nullable(aliases))
end

"""
    format(::DictFormatter, ::Record) -> Dict

Converts :date, :lookup and :stacktrace to strings
and dicts respectively.
"""
function format(fmt::DictFormatter, rec::Record)
    aliases = if isnull(fmt.aliases)
        names = fieldnames(typeof(rec))
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

    return dict
end
