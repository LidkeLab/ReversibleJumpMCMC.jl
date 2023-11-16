using Documenter
using ReversibleJumpMCMC

makedocs(
    modules = [ReversibleJumpMCMC],
    sitename = "ReversibleJumpMCMC",
    format = Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://LidkeLab.github.io/ReversibleJumpMCMC.jl",
    edit_link="main",
    assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
    warnonly=true,
)


deploydocs(;
    repo="github.com/LidkeLab/ReversibleJumpMCMC.jl.git",
    devbranch = "main"
)
