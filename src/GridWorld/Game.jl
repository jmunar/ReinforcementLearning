
using ReinforcementLearningSutton.Commons: Game, Indexable, I2, T2, TN, tuple2index
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

struct GameGridWorldBase{TS <: TN, TA <: TN} <: Game
    dims::TS
    state::Base.RefValue{Indexable{TS}}

    state_start::Indexable{TS}
    state_goal::Indexable{TS}

    states::Vector{Indexable{TS}}
    actions::Vector{Indexable{TA}}

    function GameGridWorldBase{TS, TA}(dims::TS, pos_start::TS, pos_goal::TS, allowed_movements::Vector{TA}) where {TS <: TN, TA <: TN}
        state_start = Indexable{TS}(pos_start, tuple2index(dims, pos_start))
        state_goal = Indexable{TS}(pos_goal, tuple2index(dims, pos_goal))
        state = Indexable{TS}(pos_start, tuple2index(dims, pos_start))

        states = [Indexable{TS}((x, y), tuple2index(dims, (x, y))) for y in 1:dims[2] for x in 1:dims[1]]
        actions = map(((i, m), ) -> Indexable{TA}(m, i), enumerate(allowed_movements))
        new(dims, Ref(state), state_start, state_goal, states, actions)
    end
end

dims(game::GameGridWorldBase) = game.dims
state(game::GameGridWorldBase) = game.state[]
state(game::GameGridWorldBase{TS, TA}, pos::TS) where {TS <: TN, TA <: TN} = Indexable{TS}(pos, tuple2index(dims(game), pos))
state_set(game::GameGridWorldBase, state::Indexable) = begin game.state[] = state; nothing end
states(game::GameGridWorldBase) = game.states
actions(game::GameGridWorldBase) = actions(game, state(game))

const GameGridWorldStaticBase = GameGridWorldBase{T2, T2}

nrows(game::GameGridWorldStaticBase)::Int = dims(game)[2]
ncols(game::GameGridWorldStaticBase)::Int = dims(game)[1]

actions(game::GameGridWorldStaticBase, state::I2)::Array{I2, 1} = game.actions
finished(game::GameGridWorldStaticBase)::Bool = (state(game) == game.state_goal)
restart(game::GameGridWorldStaticBase) = state_set(game, game.state_start)

function update(game::GameGridWorldStaticBase, action::I2)::Int
    s0 = state(game)
    pos_x = max(1, min(s0.value[1] + action.value[1], ncols(game)))
    pos_y = max(1, min(s0.value[2] + action.value[2], nrows(game)))
    s = state(game, (pos_x, pos_y))
    state_set(game, s)
    -1
end
