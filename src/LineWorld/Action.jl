
using ReinforcementLearningSutton.Commons: Action
import ReinforcementLearningSutton.Commons: index

struct ActionLineWorldStatic <: Action
    max_jump::Int
    move::Int
    index::Int
    
    ActionLineWorldStatic(max_jump::Int, move::Int) = new(max_jump, move, max_jump + move + (move < 0 ? 1 : 0))
end

index(action::ActionLineWorldStatic) = action.index
