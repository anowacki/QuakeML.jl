using Documenter, QuakeML

makedocs(
    sitename = "QuakeML.jl documentation",
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md",
        "Function index" => "function-index.md",
        ]
    )

deploydocs(
    repo = "github.com/anowacki/QuakeML.jl.git",
)
