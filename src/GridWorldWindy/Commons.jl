
"Stores the state of a game"
struct State
    nrows::Int
    ncols::Int
    pos::Point

    function State(nrows::Integer, ncols::Integer, pos::Point)
        if (nrows < 1)
            error("Invalid state definition: nrows must be ≧ 1")
        elseif (ncols < 1)
            error("Invalid state definition: cols must be ≧ 1")
        elseif (pos.x < 1) | (pos.x > ncols)
            error("Invalid state definition: x must be 1 ≦ x ≦ ncols")
        elseif (pos.y < 1) | (pos.y > nrows)
            error("Invalid state definition: y must be 1 ≦ y ≦ nrows")
        else
            new(nrows, ncols, pos)
        end
    end
end

function State(nrows::Integer, ncols::Integer, index::Integer)
    pos_y, pos_x = fldmod(index - 1, ncols) .+ 1
    State(nrows, ncols, Point(pos_x, pos_y))
end

function Base.show(io::IO, m::State)
  print(io, "State(pos=", m.pos, ")")
end

"Convert state to index"
function index(state::State)::Int
    return state.pos.x + state.ncols * (state.pos.y - 1)
end

"Number of states, given board dimensions"
nstates(nrows::Integer, ncols::Integer)::Int = nrows * ncols
nstates(track::Array{Int, 2})::Int = nstates(size(track)...)

abstract type Action end

function Base.show(io::IO, m::Action)
    print(io, "Action", m.vector)
end
