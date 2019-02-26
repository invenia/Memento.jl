using Documenter
using Memento

makedocs(
    modules=[Memento, Memento.TestUtils],
    format=Documenter.HTML(prettyurls=(get(ENV, "CI", nothing) == "true")),
    repo="https://github.com/invenia/Memento.jl/blob/{commit}{path}#L{line}",
    sitename="Memento.jl",
    authors="Invenia Technical Computing Corporation and contributors.",
    assets = ["assets/invenia.css"],
    pages=Any[
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
            "faq/logging-to-syslog.md",
            "faq/json-formatting.md",
            "faq/pkg-usage.md",
        ],
        "API" => Any[
            "api/public.md",
            "api/private.md",
        ],
        "Contributing" => "contributing.md",
    ],
)

deploydocs(repo="github.com/invenia/Memento.jl.git", target="build")
