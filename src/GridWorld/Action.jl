
using ReinforcementLearningSutton.Commons: Action
import ReinforcementLearningSutton.Commons: index

"Base type for an action in the 2D grid world"
abstract type ActionGridWorld <: Action end

struct ActionGridWorldStatic <: ActionGridWorld
    move::Tuple{Int, Int}
    index::Int
end

index(action::ActionGridWorldStatic)::Int = action.index

_ActionGridWorldStaticSets = Dict(
    "cross" => [
        ActionGridWorldStatic(( 1,  0), 1),
        ActionGridWorldStatic(( 0,  1), 2),
        ActionGridWorldStatic((-1,  0), 3),
        ActionGridWorldStatic(( 0, -1), 4)],
    "queen" => [
        ActionGridWorldStatic(( 1,  0), 1),
        ActionGridWorldStatic(( 1,  1), 2),
        ActionGridWorldStatic(( 0,  1), 3),
        ActionGridWorldStatic((-1,  1), 4),
        ActionGridWorldStatic((-1,  0), 5),
        ActionGridWorldStatic((-1, -1), 6),
        ActionGridWorldStatic(( 0, -1), 7),
        ActionGridWorldStatic(( 1, -1), 8)],
    "queen_plus_freeze" => [
        ActionGridWorldStatic(( 1,  0), 1),
        ActionGridWorldStatic(( 1,  1), 2),
        ActionGridWorldStatic(( 0,  1), 3),
        ActionGridWorldStatic((-1,  1), 4),
        ActionGridWorldStatic((-1,  0), 5),
        ActionGridWorldStatic((-1, -1), 6),
        ActionGridWorldStatic(( 0, -1), 7),
        ActionGridWorldStatic(( 1, -1), 8),
        ActionGridWorldStatic(( 0,  0), 9)]
)
