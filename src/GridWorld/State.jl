
using ReinforcementLearningSutton.Commons: State
import ReinforcementLearningSutton.Commons: index

"Base type for a state in the 2D grid world
Concrete implementations must implement methods:
* index(state)"
abstract type StateGridWorld <: State end

"Stores the state of a game"
struct StateGridWorldStatic <: StateGridWorld
    pos::Tuple{Int, Int}
    pos0::Tuple{Int, Int}
    nrows::Int
    ncols::Int
    index::Int

    function StateGridWorldStatic(pos::Tuple{Int, Int}, nrows::Int, ncols::Int, pos0::Tuple{Int, Int} = (1, 1))
        if ~(pos0[2] <= pos[2] <= pos0[2] + nrows - 1)
            error("Invalid state definition: y must be y0 ≦ y ≦ y0 + nrows - 1")
        elseif ~(pos0[1] <= pos[1] <= pos0[1] + ncols - 1)
            error("Invalid state definition: x must be x0 ≦ x ≦ x0 + ncols - 1")
        else
            index = (pos[1] - pos0[1] + 1) + ncols * (pos[2] - pos0[2])
            new(pos, pos0, nrows, ncols, index)
        end
    end
end

index(state::StateGridWorldStatic)::Int = state.index
pos(state::StateGridWorldStatic)::Tuple{Int, Int} = state.pos
Base.show(io::IO, m::StateGridWorldStatic) = print(io, "State(pos=", pos(m), ")")
