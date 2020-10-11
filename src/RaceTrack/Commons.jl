
"Stores the state of a game"
struct State
    nrows::Int
    ncols::Int
    pos::Point
    speed::Point
    valid::Bool

    function State(nrows::Integer, ncols::Integer, pos::Point, speed::Point)
        valid = ((nrows > 0) & (ncols > 0) & (1 <= pos.x <= ncols)
                 & (1 <= pos.y <= nrows) & (0 <= speed.x <= 4) & (0 <= speed.y <= 4))
        new(nrows, ncols, pos, speed, valid)
    end
end

function State(nrows::Integer, ncols::Integer, index::Integer)
    index, speed_x = fldmod(index - 1, 5)
    index, speed_y = fldmod(index, 5)
    pos_y, pos_x = fldmod(index, ncols) .+ 1
    State(nrows, ncols, Point(pos_x, pos_y), Point(speed_x, speed_y))
end

function Base.show(io::IO, m::State)
  print(io, "State(pos=", m.pos, ", speed=", m.speed, ")")
end

"Convert state to index, if state is a valid one"
function index(state::State)::Int
    if !state.valid
        error("Invalid state: ", state)
    else
        state.speed.x + 5 * (state.speed.y + 5 * (state.pos.x - 1 + state.ncols * (state.pos.y - 1))) + 1
    end
end

"Number of states, given board dimensions"
nstates(nrows::Integer, ncols::Integer)::Int = 25 * nrows * ncols
nstates(track::Array{Int, 2})::Int = nstates(size(track)...)

"Stores a player's action of a game"
struct Action
    acc::Point
    valid::Bool

    function Action(acc::Point)
        valid = (-1 <= acc.x <= 1) & (-1 <= acc.y <= 1)
        new(acc, valid)
    end
end

function Action(index::Integer)
    acc_y, acc_x = fldmod(index - 1, 3) .- 1
    Action(Point(acc_x, acc_y))
end

function Base.show(io::IO, m::Action)
    print(io, "Action(acc=", m.acc, ")")
end

"Convert action to index, if action is a valid one"
function index(action::Action)::Int
    if !action.valid
        error("Invalid action: ", action)
    else
        (action.acc.x + 1) + 3 * (action.acc.y + 1) + 1
    end
end

nactions()::Int = 9

function action_valid(state::State, action::Action)::Bool
    new_speed = state.speed + action.acc
    (0 <= new_speed.x < 5) & (0 <= new_speed.y < 5) & ((new_speed.x != 0) | (new_speed.y != 0))
end

function action_random(state::State)
    action = Action(1)
    while true
        action = Action(rand(1:nactions()))
        if action_valid(state, action)
            return action
        end
    end
end

# All cells crossed in one movement from (0, 0) to (x, y), x ≥ y, excluding both edges
crossings = Dict(
    Point(0, 0) => Array{Point, 1}(undef, 0),
    Point(1, 0) => Array{Point, 1}(undef, 0),
    Point(1, 1) => Array{Point, 1}(undef, 0),
    Point(2, 0) => [Point(1, 0)],
    Point(2, 1) => [Point(1, 0), Point(1, 1)],
    Point(2, 2) => [Point(1, 1)],
    Point(3, 0) => [Point(1, 0), Point(2, 0)],
    Point(3, 1) => [Point(1, 0), Point(2, 1)],
    Point(3, 2) => [Point(1, 0), Point(1, 1), Point(2, 1), Point(2, 2)],
    Point(3, 3) => [Point(1, 1), Point(2, 2)],
    Point(4, 0) => [Point(1, 0), Point(2, 0), Point(3, 0)],
    Point(4, 1) => [Point(1, 0), Point(2, 0), Point(2, 1), Point(3, 1)],
    Point(4, 2) => [Point(1, 0), Point(1, 1), Point(2, 1), Point(3, 1), Point(3, 2)],
    Point(4, 3) => [Point(1, 0), Point(1, 1), Point(2, 1), Point(2, 2), Point(3, 2), Point(3, 3)],
    Point(4, 4) => [Point(1, 1), Point(2, 2), Point(3, 3)]
)

for (k, v) in crossings
    crossings[t(k)] = t(v)
end
