
using ReinforcementLearningSutton.Commons: Point, State
import ReinforcementLearningSutton.Commons: index

"Base type for a state in the 2D grid world
Concrete implementations must implement methods:
* index(state)"
abstract type StateGridWorld <: State end

"Stores the state of a game"
struct StateGridWorldStatic <: StateGridWorld
    nrows::Int
    ncols::Int
    pos::Point
    index::Int

    function StateGridWorldStatic(nrows::Integer, ncols::Integer, pos::Point)
        if ~(1 <= pos.y <= nrows)
            error("Invalid state definition: y must be 1 ≦ y ≦ nrows")
        elseif ~(1 <= pos.x <= ncols)
            error("Invalid state definition: x must be 1 ≦ x ≦ ncols")
        else
            index = pos.x + ncols * (pos.y - 1)
            new(nrows, ncols, pos, index)
        end
    end
end

function Base.show(io::IO, m::StateGridWorldStatic)
  print(io, "State(pos=", m.pos, ")")
end

"Convert state to index"
function index(state::StateGridWorldStatic)::Int
    return state.index
end


struct StateGridWorldDynamic <: StateGridWorld
    static::StateGridWorldStatic
    max_speed::Int
    speed::Point
end
