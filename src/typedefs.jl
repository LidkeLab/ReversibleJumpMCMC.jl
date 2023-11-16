
"""
    RJMCMCStruct

A structure that contains information required for creating and running a Reversible Jump Markov Chain Monte Carlo (RJMCMC) chain.

# Fields
- `burnin::Int`: The number of steps for the burn-in phase of the chain. During this phase, the chain is allowed to converge towards a stationary distribution.
- `iterations::Int`: The number of steps for the actual chain that will be returned. This is the part of the chain that is used for inference.
- `njumptypes::Int`: The number of different types of jumps that can be proposed.
- `jumpprobability::Distributions.Categorical`: A categorical distribution that represents the probability mass function for selecting each jump type.
- `proposalfuns::Vector{Function}`: An array of proposal functions. Each function should take the current state and a Metropolis-Hastings sampler as input and return a proposed state and any additional arguments needed for the acceptance function.
- `acceptfuns::Vector{Function}`: An array of acceptance functions. Each function should take the current state, proposed state, Metropolis-Hastings sampler, and any additional arguments from the proposal function as input and return the acceptance probability.

# Function Signatures
The proposal and acceptance functions must have the following signatures:

    (proposedstate, vararg) = proposalfuns[jt](mhs, currentstate)
    α = acceptfuns[jt](mhs, currentstate, proposedstate, vararg)

where `jt` is the index of the jump type, `mhs` is a structure passed to the functions, `currentstate` is the current state of the chain, `proposedstate` is the proposed state, `vararg` is any additional arguments needed to be passed between related propose and accept functions, and `α` is the acceptance probability.
"""
mutable struct RJMCMCStruct
    burnin::Int
    iterations::Int
    njumptypes::Int 
    jumpprobability::Distributions.Categorical
    proposalfuns::Vector{Function} 
    acceptfuns::Vector{Function} 
end

"""
    RJChain

A structure that represents a Reversible Jump Markov Chain Monte Carlo (RJMCMC) chain.

# Fields
- `n::Int`: The number of jumps in the chain. Each jump represents a transition from one state to another.
- `states::Vector{Any}`: A vector of states in the chain. Each state represents a point in the parameter space.
- `jumptypes::Vector{Int}`: A vector of the attempted jump types from the current state. Each jump type corresponds to a different type of transition that can be proposed.
- `α::Vector{Float64}`: A vector of acceptance probabilities for each proposed state. The acceptance probability determines whether a proposed state is accepted or rejected.
- `accept::Vector{Bool}`: A vector of results from the acceptance calculation. Each element is a boolean indicating whether the corresponding proposed state was accepted (true) or rejected (false).
- `proposedstates::Vector{Any}`: A vector of proposed states. Each proposed state is a potential next state in the chain.

# Constructor
The constructor for `RJChain` takes an integer `n` and initializes a chain with `n` jumps. All vectors are initialized with `n` elements. The `states`, `α`, and `proposedstates` vectors are initialized with undefined values, the `jumptypes` vector is initialized with zeros, and the `accept` vector is initialized with `false`.
"""
mutable struct RJChain
    n::Int
    states::Vector{Any}
    jumptypes::Vector{Int}
    α::Vector{Float64}
    accept::Vector{Bool}
    proposedstates::Vector{Any}
end

"""
    RJChain(n::Int)

Constructs a new `RJChain` with `n` jumps.

# Arguments
- `n::Int`: The number of jumps in the chain.

# Returns
- A new `RJChain` with `n` jumps. The `states`, `α`, and `proposedstates` vectors are initialized with undefined values, the `jumptypes` vector is initialized with zeros, and the `accept` vector is initialized with `false`.
"""
RJChain(n::Int) = RJChain(n,
    Vector{Any}(undef, n),
    zeros(Int, n),
    Vector{Float64}(undef, n),
    falses(n),
    Vector{Any}(undef, n)
)

function length(rjc::RJChain)
    return rjc.n
end
