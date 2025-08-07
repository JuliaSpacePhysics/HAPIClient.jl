using Documenter
using HAPIClient

makedocs(;
    modules=[HAPIClient],
    sitename="HAPIClient.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
    ),
    pages=[
        "Home" => "index.md",
        "Usage" => "usage.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaSpacePhysics/HAPIClient.jl",
    push_preview = true
)
