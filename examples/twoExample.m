# Explore a 1D Gaussian PDF using a basic MCMC chain
using ReversibleJumpMCMC
using Distributions
using Plots

# setup a MH structure that gets passed around inside RJMMCMC
struct MHStruct
    σ::Float32 # metropolis hasting jump size
end
mhs = MHStruct(1f0)

# setup a state type
mutable struct state1D 
    x,y::Float32
end

# setup proposal and acceptance functions
function mypropose1(mhs::MHStruct, s::state1D)
    teststate = state1D(s.x + mhs.σ * randn(Float32))
    return teststate, 0
end
function mypropose2(mhs::MHStruct, s::state1D)
    teststate = state1D(s.y + mhs.σ * randn(Float32))
    return teststate, 0
end
function myaccept1(mhs::MHStruct, s::state1D, teststate::state1D, vararg)
    σ = 5f0
    d = Normal(0f0, σ)
    α = pdf(d, teststate.x) / pdf(d, s.x)
    return α
end
function myaccept2(mhs::MHStruct, s::state1D, teststate::state1D, vararg)
    σ = 5f0
    d = Normal(0f0, σ)
    α = pdf(d, teststate.y) / pdf(d, s.y)
    return α
end

# setup the RJMCMCStruct
burnin = Int32(1000)
iterations = Int32(10000)
njumptypes = 2 # number of jump types for RJMCMC
jumpprobability = [0.5, 0.5] # vector
proposalfuns = [mypropose1, mypropose2] # vector
acceptfuns = [myaccept1, myaccept2] # vector
rjs = ReversibleJumpMCMC.RJMCMCStruct(burnin, iterations, njumptypes, jumpprobability, proposalfuns, acceptfuns)

# initial state
state0 = state1D(0f0)

# run chain
rjc = ReversibleJumpMCMC.buildchain(rjs, mhs, state0)

# extract states
xchain = zeros(Float32, iterations)
for ii = 1:iterations
    xchain[ii] = rjc.states[ii].x
end

# plot found distributions
gr()
plt = histogram(xchain, normalize=true, xlabel="θ", ylabel="pdf(θ",label="mcmc dist.")

# true pdf
xvec = (-20:20)
σ = 5f0
d = Normal(0f0, σ)
plot!(plt,xvec,pdf.(d, xvec),label="true pdf")