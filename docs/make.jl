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
        ],
        "FAQ" => "faq.md",
        "API" => "api.md",
    ]
)

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/invenia/Memento.jl.git",
    julia  = "0.5",
    osname = "osx"
)
