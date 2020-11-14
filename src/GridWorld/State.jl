
using ReinforcementLearningSutton.Commons: Point, State
import ReinforcementLearningSutton.Commons: index

"Base type for a state in the 2D grid world
Concrete implementations must implement methods:
* index(state)"
abstract type StateGridWorld <: State end

"Stores the state of a game"
struct StateGridWorldStatic <: StateGridWorld
    pos::Point
    pos0::Point
    nrows::Int
    ncols::Int
    index::Int

    function StateGridWorldStatic(pos::Point, nrows::Int, ncols::Int, pos0::Point = Point(1, 1))
        if ~(pos0.y <= pos.y <= pos0.y + nrows - 1)
            error("Invalid state definition: y must be y0 ≦ y ≦ y0 + nrows - 1")
        elseif ~(pos0.x <= pos.x <= pos0.x + ncols - 1)
            error("Invalid state definition: x must be x0 ≦ x ≦ x0 + ncols - 1")
        else
            index = (pos.x - pos0.x + 1) + ncols * (pos.y - pos0.y)
            new(pos, pos0, nrows, ncols, index)
        end
    end
end

index(state::StateGridWorldStatic)::Int = state.index
pos(state::StateGridWorldStatic)::Point = state.pos
Base.show(io::IO, m::StateGridWorldStatic) = print(io, "State(pos=", pos(m), ")")
