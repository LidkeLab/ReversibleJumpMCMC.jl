module ReversibleJumpMCMC

using Plots

"""
    RJMCMCStruct

Contains information about creating the chain

# Fields
- `burnin::Int32`: number of steps for chain burn in.
- `iterations::Int32' : number of steps for the returned chain
- `njumptypes::Int32' : number of different jump types
- `jumpprobability::Vector{Float32}' : probability mass function for jump type selection
- `proposalfuns' :  array of functions for proposal functions
- `acceptfuns' :  array of functions for acceptance functions

proposal and acceptance functions must have the signature

    (proposedstate,vararg)=proposalfuns[jt](mhs,currentstate)     
    α=acceptfuns[jt](mhs,currentstate,proposedstate,vararg)

where jt is the index of the jumptype, mhs is structure passed to the functions, and vararg is anything needed to be passed
between related propose and accept fucntions 
"""
mutable struct RJMCMCStruct
    burnin::Int32
    iterations::Int32
    njumptypes::Int32 #number of jump types for RJMCMC
    jumpprobability::Vector{Float32} #sums to 1
    proposalfuns
    acceptfuns
end

"""
    RJChain

Contains information about the chain including a vector of accepted states

# Fields
- `n::Int32 : number of jumps in chain 
- `states::Vector{Any} : vector of states 
- `jumptypes::Vector{Int32} : vector of the attempted jumptype from the current state
- `α::Vector{Float32} : vector of acceptance probabilities from proposed state 
- `accept::Vector{Bool} : vector of results from acceptance calculation
- 'proposedstates::Vector{Any}' : vector of proposed states

"""
mutable struct RJChain  #this is the main output of RJMCMC
    n::Int32  #number of jumps in chain 
    states::Vector{Any}
    jumptypes::Vector{Int32}
    α::Vector{Float32}
    accept::Vector{Bool}
    proposedstates::Vector{Any}
end
RJChain(n::Int32)=RJChain(n,
Vector{Any}(undef,n),
zeros(Int32,n),
Vector{Float32}(undef,n),
Vector{Bool}(undef,n),
Vector{Any}(undef,n)
)
function length(rjc::RJChain)
    return rjc.n
end


function initchain(rjs::RJMCMCStruct,burninchain::RJChain) #this gets last state of burnin chain and intializes new chain
    newchain=RJChain(rjs.iterations)
    newchain.states[1]=burninchain.states[burninchain.n]
    newchain.accept[1]=1
    newchain.α[1]=1
    newchain.jumptypes[1]=0
    newchain.proposedstates[1]=burninchain.states[burninchain.n]    
return newchain
end

function initchain(rjs::RJMCMCStruct,intialstate) #this initializes new chain given an intial state and configures a burnin
    njumps=Int32(max(rjs.burnin,1)); #handle zero burn in case
    newchain=RJChain(njumps)
    newchain.states[1]=intialstate
    newchain.accept[1]=1
    newchain.α[1]=1
    newchain.jumptypes[1]=0
    newchain.proposedstates[1]=intialstate
return newchain
end

function jtrand(rjs::RJMCMCStruct) #select a jump type
    r=rand(Float32);
    jt=1
    tmp=rjs.jumpprobability[jt]
    while r>tmp
        jt+=1
        if jt==rjs.njumptypes
            break
        end
        tmp+=rjs.jumpprobability[jt]
    end    
    return jt
end

"""
    buildchain(rjs::RJMCMCStruct,mhs,intialstate)

Generate RJMCMC chain and returns a RJChain struct.   
"""
function buildchain(rjs::RJMCMCStruct,mhs,intialstate)
    
    #init and burnin    
    bchain=initchain(rjs,intialstate)
    if rjs.burnin>0
        runchain!(rjs,bchain,rjs.burnin,mhs)
    end

    #real chain
    chain=initchain(rjs,bchain)
    runchain!(rjs,chain,rjs.iterations,mhs)

    return chain
end


function runchain!(rjs::RJMCMCStruct,rjc::RJChain,iterations,mhs)
    for nn=1:iterations-1
        jt=jtrand(rjs)
        # println(jt)
        rjc.jumptypes[nn]=jt;

        #get proposal
        mtest,vararg=rjs.proposalfuns[jt](mhs,rjc.states[nn])     
        rjc.proposedstates[nn+1]=mtest;
        
        #calculate acceptance probability
        α=rjs.acceptfuns[jt](mhs,rjc.states[nn],mtest,vararg)
        rjc.α[nn+1]=α;

        #update chain
        if α>rand()
            rjc.accept[nn+1]=1;
            rjc.states[nn+1]=mtest;
        else
            rjc.accept[nn+1]=0;
            rjc.states[nn+1]=rjc.states[nn];
        end
       
        #println((nn,jt,α))
    end
end


#tools

function showacceptratio(rjc::RJChain)
    steps=rjc.n 
    nstates=maximum(rjc.jumptypes)
    attempts=zeros(Int32,nstates)
    accepts=zeros(Float32,nstates)

    for nn=1:steps-1
        jt=rjc.jumptypes[nn]
        attempts[jt]+=1
        if rjc.accept[nn+1]
            accepts[jt]+=1
        end
    end


    for nn=1:nstates
        if attempts[nn]>0
            accepts[nn]=accepts[nn]./attempts[nn] 
        else
            accepts[nn]=0
        end
    end

    gr()
    plt=bar((1:nstates),accepts)
    display(plt)       
    return accepts,plt
end




end

