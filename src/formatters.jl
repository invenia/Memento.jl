using JSON

abstract Formatter

const DEFAULT_FMT_STRING = "{date} - {level}: {msg}"

immutable DefaultFormatter <: Formatter
    fmt_str::AbstractString

    function DefaultFormatter(fmt_str::AbstractString=DEFAULT_FMT_STRING)
        new(fmt_str)
    end
end

function format(fmt::DefaultFormatter, rec::Record)
    rec_dict = copy(getdict(rec))
    result = fmt.fmt_str

    for field in keys(rec_dict)
        if is(field, :lookup)
            # lookup is a StackFrame
            name, file, line = rec_dict[field].func, rec_dict[field].file, rec_dict[field].line
            rec_dict[field] = "$(name)@$(basename(string(file))):$(line)"
        elseif is(field, :stacktrace)
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

    rec_dict[:date] = string(l[:date])
    rec_dict[:lookup] = Dict(
        :name => rec_dict[:lookup].func,
        :file => basename(string(rec_dict[:lookup].file)),
        :line => rec_dict[:lookup].line
    )
    rec_dict[:stacktrace] = map(
        f -> Dict(:name => f.func, :file => basename(string(f.file)), :line => f.line),
        rec_dict[:stacktrace]
    )

    return json(rec_dict)
end
