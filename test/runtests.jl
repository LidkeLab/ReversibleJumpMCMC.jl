using Test
using ReversibleJumpMCMC
using Distributions

# Test function
@testset "1D Gaussian PDF Exploration using MCMC" begin
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

    # Extract states
    xchain = zeros(Float32, iterations)
    for ii = 1:iterations
        xchain[ii] = rjc.states[ii].x
    end

    # Example Test (You should add more specific tests)
    @test length(xchain) == iterations
end
