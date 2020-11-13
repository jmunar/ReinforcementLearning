
using ReinforcementLearningSutton.Commons: Action
import ReinforcementLearningSutton.Commons: index

"Base type for an action in the 2D grid world"
abstract type ActionGridWorld <: Action end

struct ActionGridWorldStatic <: ActionGridWorld
    move::Point
    index::Int
end

index(action::ActionGridWorldStatic)::Int = action.index

_ActionGridWorldStaticSets = Dict(
    "cross" => [
        ActionGridWorldStatic(Point( 1,  0), 1),
        ActionGridWorldStatic(Point( 0,  1), 2),
        ActionGridWorldStatic(Point(-1,  0), 3),
        ActionGridWorldStatic(Point( 0, -1), 4)],
    "queen" => [
        ActionGridWorldStatic(Point( 1,  0), 1),
        ActionGridWorldStatic(Point( 1,  1), 2),
        ActionGridWorldStatic(Point( 0,  1), 3),
        ActionGridWorldStatic(Point(-1,  1), 4),
        ActionGridWorldStatic(Point(-1,  0), 5),
        ActionGridWorldStatic(Point(-1, -1), 6),
        ActionGridWorldStatic(Point( 0, -1), 7),
        ActionGridWorldStatic(Point( 1, -1), 8)],
    "queen_plus_freeze" => [
        ActionGridWorldStatic(Point( 1,  0), 1),
        ActionGridWorldStatic(Point( 1,  1), 2),
        ActionGridWorldStatic(Point( 0,  1), 3),
        ActionGridWorldStatic(Point(-1,  1), 4),
        ActionGridWorldStatic(Point(-1,  0), 5),
        ActionGridWorldStatic(Point(-1, -1), 6),
        ActionGridWorldStatic(Point( 0, -1), 7),
        ActionGridWorldStatic(Point( 1, -1), 8),
        ActionGridWorldStatic(Point( 0,  0), 9)]
)
