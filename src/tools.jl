

function acceptratios(rjc::RJChain)
    steps = rjc.n
    nstates = maximum(rjc.jumptypes)
    attempts = zeros(Int32, nstates)
    accepts = zeros(Float32, nstates)

    for nn = 1:steps-1
        jt = rjc.jumptypes[nn]
        attempts[jt] += 1
        if rjc.accept[nn+1]
            accepts[jt] += 1
        end
    end

    for nn = 1:nstates
        if attempts[nn] > 0
            accepts[nn] = accepts[nn] ./ attempts[nn]
        else
            accepts[nn] = 0
        end
    end

    return accepts
end


