

using ReinforcementLearningSutton.Commons: State
import ReinforcementLearningSutton.Commons: index

struct StateLineWorldStatic <: State
    nstates::Int
    pos::Int
    index::Int
    
    StateLineWorldStatic(nstates::Int, pos::Int) = new(nstates, pos, pos + 1)
end

index(state::StateLineWorldStatic) = state.index