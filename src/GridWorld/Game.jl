
using ReinforcementLearningSutton.Commons: Game, Point
import ReinforcementLearningSutton.Commons: state, state_set, nstates, states, actions, finished, restart, update

"Base type for a game in the 2D grid world
Concrete implementations must implement methods:
* state(game)
* state_set(game, state)
* states(game)
* actions(game)
* actions(game, state)
* finished(game) -> bool
* restart(game)
* update(game, action) -> reward
* nrows(game)
* ncols(game)"
abstract type GameGridWorld <: Game end

struct GameGridWorldStaticBase <: GameGridWorld
    nrows::Int
    ncols::Int
    state::Base.RefValue{StateGridWorldStatic}

    state_start::StateGridWorldStatic
    state_goal::StateGridWorldStatic
    allowed_movements::String
    allowed_movements_list::Array{ActionGridWorldStatic, 1}

    function GameGridWorldStaticBase(nrows::Int, ncols::Int, pos_start::Point, pos_goal::Point, allowed_movements::String)
        state_start = StateGridWorldStatic(nrows, ncols, pos_start)
        state_goal = StateGridWorldStatic(nrows, ncols, pos_goal)
        state = StateGridWorldStatic(nrows, ncols, pos_start)
        allowed_movements_list = _ActionGridWorldStaticSets[allowed_movements]
        new(nrows, ncols, Ref(state), state_start, state_goal, allowed_movements, allowed_movements_list)
    end
end

state(game::GameGridWorldStaticBase)::StateGridWorldStatic = game.state[]
state_set(game::GameGridWorldStaticBase, state::StateGridWorldStatic) = (game.state[] = state)
nstates(game::GameGridWorldStaticBase)::Int = game.nrows * game.ncols

function states(game::GameGridWorldStaticBase)::Array{StateGridWorldStatic, 1}
    nr, nc = nrows(game), ncols(game)
    [StateGridWorldStatic(nr, nc, Point(x, y)) for y in 1:nr for x in 1:nc]
end

actions(game::GameGridWorldStaticBase)::Array{ActionGridWorldStatic, 1} = actions(game, state(game))
actions(game::GameGridWorldStaticBase, state::StateGridWorldStatic)::Array{ActionGridWorldStatic, 1} = game.allowed_movements_list
finished(game::GameGridWorldStaticBase)::Bool = (state(game) == game.state_goal)
restart(game::GameGridWorldStaticBase) = state_set(game, game.state_start)
nrows(game::GameGridWorldStaticBase)::Int = game.nrows
ncols(game::GameGridWorldStaticBase)::Int = game.ncols

function update(game::GameGridWorldStaticBase, action::ActionGridWorldStatic)::Int
    s0 = state(game)
    pos_x = max(1, min(s0.pos.x + action.move.x, ncols(game)))
    pos_y = max(1, min(s0.pos.y + action.move.y, nrows(game)))
    s = StateGridWorldStatic(nrows(game), ncols(game), Point(pos_x, pos_y))
    state_set(game, s)
    -1
end

struct GameGridWorldStatic{RulesetType} <: GameGridWorld
    game::GameGridWorldStaticBase
    ruleset::RulesetType
end

state(game::GameGridWorldStatic)::StateGridWorldStatic = state(game.game)
state_set(game::GameGridWorldStatic, state::StateGridWorldStatic) = state_set(game.game, state)
states(game::GameGridWorldStatic)::Array{StateGridWorldStatic, 1} = states(game.game)
actions(game::GameGridWorldStatic)::Array{ActionGridWorldStatic, 1} = actions(game.game)
actions(game::GameGridWorldStatic, state::StateGridWorldStatic)::Array{ActionGridWorldStatic, 1} = actions(game.game, state)
finished(game::GameGridWorldStatic)::Bool = finished(game.game)
restart(game::GameGridWorldStatic) = restart(game.game)
nrows(game::GameGridWorldStatic)::Int = nrows(game.game)
ncols(game::GameGridWorldStatic)::Int = ncols(game.game)
