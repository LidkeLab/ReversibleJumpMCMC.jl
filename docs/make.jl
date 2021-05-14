push!(LOAD_PATH,"../src/")

using Documenter
using RJMCMC

makedocs(
    sitename = "RJMCMC",
    format = Documenter.HTML(),
    modules = [RJMCMC]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.

deploydocs(;
    repo="github.com/LidkeLab/RJMCMC.jl.git",
    devbranch = "main"
)