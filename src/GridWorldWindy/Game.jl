
struct Game
    grid_wind::Array{Point, 2}
    pos_start::Point
    pos_goal::Point
end

function nrows(game::Game)::Int
    size(game.grid_wind)[2]
end

function ncols(game::Game)::Int
    size(game.grid_wind)[1]
end

function Base.show(io::IO, m::Game)
    print(io, "Game(", ncols(m), "x", nrows(m), ", s=", m.pos_start, ", g=", m.pos_goal, ")")
end

function state_update(game::Game, state::State, action::Action)::State
    pos_x = max(1, min(state.pos.x + action.vector.x, state.ncols))
    pos_y = max(1, min(state.pos.y + action.vector.y, state.nrows))

    # Get wind in new position
    wind  = game.grid_wind[pos_x, pos_y]
    pos_x = max(1, min(pos_x + wind.x, ncols(game)))
    pos_y = max(1, min(pos_y + wind.y, nrows(game)))
    State(nrows(game), ncols(game), Point(pos_x, pos_y))
end

_AllActions = [Action(i) for i in 1:nactions()]
