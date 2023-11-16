# Explore a 1D Gaussian PDF using a basic MCMC chain
using ReversibleJumpMCMC
using Distributions
using CairoMakie    

# setup a MH structure that gets passed around inside RJMMCMC
struct MHStruct
    σ::Float32 # metropolis hasting jump size
end
mhs = MHStruct(1)

# setup a state type
mutable struct state1D 
    x::Float32
end

# setup proposal and acceptance functions
function mypropose(mhs::MHStruct, s::state1D)
    teststate = state1D(s.x + mhs.σ * randn())
    return teststate, 0
end

function myaccept(mhs::MHStruct, s::state1D, teststate::state1D, vararg)
    σ = 5.0
    d = Normal(0.0, σ)
    α = pdf(d, teststate.x) / pdf(d, s.x)
    return α
end

# setup the RJMCMCStruct
burnin = 100
iterations = 10000
njumptypes = 1 
jumpprobability = Categorical([1.0]) 
proposalfuns = [mypropose] 
acceptfuns = [myaccept] 
rjs = ReversibleJumpMCMC.RJMCMCStruct(burnin, iterations, njumptypes, jumpprobability, proposalfuns, acceptfuns)

# initial state
state0 = state1D(0)

# run chain
rjc = ReversibleJumpMCMC.buildchain(rjs, mhs, state0)

# extract states
xchain = zeros(Float32, iterations)
for ii = 1:iterations
    xchain[ii] = rjc.states[ii].x
end


# Create the figure and axis
fig = Figure()
ax = Axis(fig[1, 1], xlabel="θ", ylabel="pdf(θ)")

# Create the histogram
histplot = hist!(ax, xchain, normalization=:pdf)

# True pdf
xvec = -20:0.1:20
σ = 5.0
d = Normal(0.0, σ)
pdfplot = lines!(ax, xvec, pdf.(d, xvec), color=:red)

# Add legend
legend = Legend(fig, [histplot, pdfplot], ["mcmc dist.", "true pdf"])
fig[1, 2] = legend

# Display the figure
fig