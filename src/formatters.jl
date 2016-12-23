using JSON

abstract Formatter

const DEFAULT_FMT_STRING = "[{level} | {name}]: {msg}"

immutable DefaultFormatter <: Formatter
    fmt_str::AbstractString

    function DefaultFormatter(fmt_str::AbstractString=DEFAULT_FMT_STRING)
        new(fmt_str)
    end
end

function format(fmt::DefaultFormatter, rec::Record)
    rec_dict = copy(getdict(rec))
    result = fmt.fmt_str

    for field in keys(rec)
        if field === :lookup
            # lookup is a StackFrame
            name, file, line = rec_dict[field].func, rec_dict[field].file, rec_dict[field].line
            rec_dict[field] = "$(name)@$(basename(string(file))):$(line)"
        elseif field === :stacktrace
            # stacktrace is a vector of StackFrames
            rec_dict[field] = string(" stack:[",
                join(
                    map(f->"$(f.func)@$(basename(string(f.file))):$(f.line)", rec_dict[field]), ", "
                ), "]"
            )
        end

        result = replace(result, "{$field}", rec_dict[field])
    end

    return result
end


type JsonFormatter <: Formatter end

function format(fmt::JsonFormatter, rec::Record)
    rec_dict = copy(getdict(rec))

    if haskey(rec_dict, :date)
        rec_dict[:date] = string(rec_dict[:date])
    end

    if haskey(rec_dict, :lookup)
        rec_dict[:lookup] = Dict(
            :name => rec_dict[:lookup].func,
            :file => basename(string(rec_dict[:lookup].file)),
            :line => rec_dict[:lookup].line
        )
    end

    if haskey(rec_dict, :stacktrace)
        rec_dict[:stacktrace] = map(
            f -> Dict(
                :name => f.func,
                :file => basename(string(f.file)),
                :line => f.line
            ),
            rec_dict[:stacktrace]
        )
    end

    return json(rec_dict)
end
