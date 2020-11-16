
using ReinforcementLearningSutton.Commons: Action, Game, State
import ReinforcementLearningSutton.Commons: index, state, state_set, nstates, states, actions, finished, restart, update

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

function tuple2index(dims::Tuple{Int, Int}, pos::Tuple{Int, Int}, pos0::Tuple{Int, Int} = (1, 1))::Int
    (pos[1] - pos0[1] + 1) + dims[1] * (pos[2] - pos0[2])
end

struct StateGridWorldStatic <: State
    pos::Tuple{Int, Int}
    index::Int
end

index(state::StateGridWorldStatic) = state.index

struct ActionGridWorldStatic <: Action
    move::Tuple{Int, Int}
    index::Int
end

index(action::ActionGridWorldStatic) = action.index

struct GameGridWorldStaticBase <: GameGridWorld
    dims::Tuple{Int, Int}
    state::Base.RefValue{StateGridWorldStatic}

    state_start::StateGridWorldStatic
    state_goal::StateGridWorldStatic
    actions::Vector{ActionGridWorldStatic}

    function GameGridWorldStaticBase(
            dims::Tuple{Int, Int},
            pos_start::Tuple{Int, Int},
            pos_goal::Tuple{Int, Int},
            allowed_movements::Vector{Tuple{Int, Int}})
        state_start = StateGridWorldStatic(pos_start, tuple2index(dims, pos_start))
        state_goal = StateGridWorldStatic(pos_goal, tuple2index(dims, pos_goal))
        state = StateGridWorldStatic(pos_start, tuple2index(dims, pos_start))
        actions = map(((i, m), ) -> ActionGridWorldStatic(m, i), enumerate(allowed_movements))
        new(dims, Ref(state), state_start, state_goal, actions)
    end
end

dims(game::GameGridWorldStaticBase)::Tuple{Int, Int} = game.dims
nrows(game::GameGridWorldStaticBase)::Int = dims(game)[2]
ncols(game::GameGridWorldStaticBase)::Int = dims(game)[1]

state(game::GameGridWorldStaticBase)::StateGridWorldStatic = game.state[]
state(game::GameGridWorldStaticBase, pos::Tuple{Int, Int})::StateGridWorldStatic = StateGridWorldStatic(pos, tuple2index(dims(game), pos))
state_set(game::GameGridWorldStaticBase, state::StateGridWorldStatic) = (game.state[] = state)
nstates(game::GameGridWorldStaticBase)::Int = game.dims[1] * game.dims[2]

function states(game::GameGridWorldStaticBase)::Array{StateGridWorldStatic, 1}
    [state(game, (x, y)) for y in 1:nrows(game) for x in 1:ncols(game)]
end

actions(game::GameGridWorldStaticBase)::Array{ActionGridWorldStatic, 1} = actions(game, state(game))
actions(game::GameGridWorldStaticBase, state::StateGridWorldStatic)::Array{ActionGridWorldStatic, 1} = game.actions
finished(game::GameGridWorldStaticBase)::Bool = (state(game) == game.state_goal)
restart(game::GameGridWorldStaticBase) = state_set(game, game.state_start)

function update(game::GameGridWorldStaticBase, action::ActionGridWorldStatic)::Int
    s0 = state(game)
    pos_x = max(1, min(s0.pos[1] + action.move[1], ncols(game)))
    pos_y = max(1, min(s0.pos[2] + action.move[2], nrows(game)))
    s = state(game, (pos_x, pos_y))
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
