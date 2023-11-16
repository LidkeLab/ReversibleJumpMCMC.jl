
"""
    initchain(rjs::RJMCMCStruct, burninchain::RJChain)

Initialize a new RJMCMC chain using the last state of a burn-in chain.

# Arguments
- `rjs::RJMCMCStruct`: An RJMCMCStruct object that contains the number of iterations for the new chain.
- `burninchain::RJChain`: An RJChain object that represents the burn-in chain. The last state of this chain is used to initialize the new chain.

# Returns
- `newchain::RJChain`: A new RJChain object that has been initialized with the last state of the burn-in chain.
"""
function initchain(rjs::RJMCMCStruct, burninchain::RJChain) #this gets last state of burnin chain and intializes new chain
    newchain = RJChain(rjs.iterations)
    newchain.states[1] = burninchain.states[burninchain.n]
    newchain.accept[1] = 1
    newchain.α[1] = 1
    newchain.jumptypes[1] = 0
    newchain.proposedstates[1] = burninchain.states[burninchain.n]
    return newchain
end

"""
    initchain(rjs::RJMCMCStruct, initialstate)

Initialize a new RJMCMC chain using an initial state and configures a burn-in.

# Arguments
- `rjs::RJMCMCStruct`: An RJMCMCStruct object that contains the number of iterations for the new chain.
- `initialstate`: The initial state to start the new chain.

# Returns
- `newchain::RJChain`: A new RJChain object that has been initialized with the initial state and configured for burn-in.
"""
function initchain(rjs::RJMCMCStruct, intialstate) #this initializes new chain given an intial state and configures a burnin
    njumps = max(rjs.burnin, 1) #handle zero burn in case
    println("njumps = ", njumps)
    newchain = RJChain(njumps)
    newchain.states[1] = intialstate
    newchain.accept[1] = 1
    newchain.α[1] = 1
    newchain.jumptypes[1] = 0
    newchain.proposedstates[1] = intialstate
    return newchain
end

"""
    buildchain(rjs::RJMCMCStruct, mhs, initialstate)

Build a new RJMCMC chain using an initial state and a Metropolis-Hastings sampler.

# Arguments
- `rjs::RJMCMCStruct`: An RJMCMCStruct object that contains the number of iterations for the new chain.
- `mhs`: A user-defined Metropolis-Hastings parameter structure passed propose/accept functions.
- `initialstate`: The initial state to start the new chain.

# Returns
- `chain::RJChain`: A new RJChain object that has been initialized with the initial state and run for the specified number of iterations.
"""
function buildchain(rjs::RJMCMCStruct, mhs, intialstate)

    #init and burnin    
    bchain = initchain(rjs, intialstate)
    if rjs.burnin > 0
        runchain!(rjs, bchain, rjs.burnin, mhs)
    end

    #real chain
    chain = initchain(rjs, bchain)
    runchain!(rjs, chain, rjs.iterations, mhs)

    return chain
end

"""
    runchain!(rjs::RJMCMCStruct, rjc::RJChain, iterations, mhs)

Run the RJMCMC chain for a specified number of iterations using a Metropolis-Hastings sampler.

# Arguments
- `rjs::RJMCMCStruct`: An RJMCMCStruct object that contains the jump probabilities and proposal functions.
- `rjc::RJChain`: The RJChain object to run.
- `iterations`: The number of iterations to run the chain.
- `mhs`: A user-defined Metropolis-Hastings parameter structure passed propose/accept functions.

# Modifies
- `rjc::RJChain`: The RJChain object is updated with the new states, jump types, proposed states, acceptance probabilities, and acceptance states.
"""
function runchain!(rjs::RJMCMCStruct, rjc::RJChain, iterations, mhs)
    for nn = 1:iterations-1
        jt = rand(rjs.jumpprobability)
        rjc.jumptypes[nn] = jt

        #get proposal
        mtest, vararg = rjs.proposalfuns[jt](mhs, rjc.states[nn])
        rjc.proposedstates[nn+1] = mtest

        #calculate acceptance probability
        α = rjs.acceptfuns[jt](mhs, rjc.states[nn], mtest, vararg)
        rjc.α[nn+1] = α

        #update chain
        if α > rand()
            rjc.accept[nn+1] = 1
            rjc.states[nn+1] = mtest
        else
            rjc.accept[nn+1] = 0
            rjc.states[nn+1] = rjc.states[nn]
        end
    end
end


