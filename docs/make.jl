push!(LOAD_PATH,"../src/")

using Documenter
using ReversibleJumpMCMC

makedocs(
    sitename = "ReversibleJumpMCMC",
    format = Documenter.HTML(),
    modules = [ReversibleJumpMCMC]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.

deploydocs(;
    repo="github.com/LidkeLab/ReversibleJumpMCMC.jl.git",
    devbranch = "main"
)
