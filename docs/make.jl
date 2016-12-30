using Documenter
using Memento

makedocs(
    modules = [Memento],
    clean = false,
    format = :html,
    sitename = "Memento.jl",
    authors = "Rory Finnegan and contributors.",
    pages = Any[
        "Home" => "index.md",
        "Manual" => Any[
            "man/intro.md",
            "man/loggers.md",
            "man/handlers.md",
            "man/formatters.md",
            "man/records.md",
            "man/io.md",
            "man/conclusion.md",
        ],
        "FAQ" => Any[
            "faq/another-logging-lib.md",
            "faq/change-colors.md",
        ],
        "API" => Any[
            "api/public.md",
            "api/private.md",
        ],
        "Contributing" => "contributing.md",
    ]
)

deploydocs(
    repo   = "github.com/invenia/Memento.jl.git",
    julia  = "0.5",
    target = "build",
    deps = nothing,
    make = nothing,
)
