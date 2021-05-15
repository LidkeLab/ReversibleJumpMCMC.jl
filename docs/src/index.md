# Overview

ReversibleJumpMCMC.jl provides a lightweight framework for Reversible Jump Markov Chain Monte Carlo.  

The framework is based around the following code block. 

```
mtest,vararg=rjs.proposalfuns[jt](mhs,rjc.states[nn])     
α=rjs.acceptfuns[jt](mhs,rjc.states[nn],mtest,vararg)
rjc.α[nn+1]=α;
if α>rand()
    rjc.accept[nn+1]=1;
    rjc.states[nn+1]=mtest;
else
    rjc.accept[nn+1]=0;
    rjc.states[nn+1]=rjc.states[nn];
end
```

A jumptype ```jt::Int32``` is selected from a probability mass function (not shown) and used to select state proposal and acceptance functions.  

```rjs::RJMCMCStruct``` holds a vector of functions for proposal generators and acceptance calculators.    

States of the chain are accumlated in the vector ```rjc.states``` where ```rjc::RJChain``` is a struct holding the results of the RJMCMC run.  ```mhs``` is a user defined type, typically immutable, sent to all proposal and generator functions. ```vararg``` can be customized for specific proposal/acceptance functions.



