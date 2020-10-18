
abstract type Game end

_Actions4 = [Point(1, 0), Point(0, 1), Point(-1, 0), Point(0, -1)]
_Actions8 = [Point(1, 0), Point(1, 1), Point(0, 1), Point(-1, 1), Point(-1, 0), Point(-1, -1), Point(0, -1), Point(1, -1)]
_Actions9 = [Point(1, 0), Point(1, 1), Point(0, 1), Point(-1, 1), Point(-1, 0), Point(-1, -1), Point(0, -1), Point(1, -1), Point(0, 0)]

nrows(game::Game)::Int = size(game.grid_wind)[2]
ncols(game::Game)::Int = size(game.grid_wind)[1]
nstates(game::Game)::Int = nstates(nrows(game), ncols(game))
State(game::Game, i::Int) = State(nrows(game), ncols(game), i)

function actions(game::Game, state::State)::Array{Point, 1}
    if game.allowed_movements == 4
        _Actions4
    elseif game.allowed_movements == 8
        _Actions8
    else
        _Actions9
    end
end

nactions(game::Game, state::State)::Int = length(actions(game, state))

function Base.show(io::IO, m::Game)
    print(io, "Game(", ncols(m), "x", nrows(m), ", s=", m.pos_start, ", g=", m.pos_goal, ")")
end

struct GameStaticWind <: Game
    grid_wind::Array{Point, 2}
    pos_start::Point
    pos_goal::Point
    allowed_movements::Int
end

function wind(game::GameStaticWind, pos::Point)::Point
    return game.grid_wind[pos.x, pos.y]
end

struct GameStochasticWind <: Game
    grid_wind::Array{Point, 2}
    pos_start::Point
    pos_goal::Point
    allowed_movements::Int
end

function wind(game::GameStochasticWind, pos::Point)::Point
    return game.grid_wind[pos.x, pos.y] + rand([Point(0, -1), Point(0, 0), Point(0, 1)])
end


state_start(game::Game) = State(nrows(game), ncols(game), game.pos_start)

function state_update(game::Game, state::State, action::Point)::Tuple{Int, State}
    w  = wind(game, state.pos)
    pos_x = max(1, min(state.pos.x + action.x + w.x, state.ncols))
    pos_y = max(1, min(state.pos.y + action.y + w.y, state.nrows))
    (-1, State(state.nrows, state.ncols, Point(pos_x, pos_y)))
end
