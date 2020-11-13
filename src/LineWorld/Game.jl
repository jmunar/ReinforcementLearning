
using ReinforcementLearningSutton.Commons: Game
import ReinforcementLearningSutton.Commons: state, state_set, nstates, states, actions, finished, restart, update

struct GameLineWorldBase <: Game
    nstates::Int
    max_jump::Int
    
    state::Base.RefValue{StateLineWorldStatic}
    state_start::StateLineWorldStatic
    
    states_all::Vector{StateLineWorldStatic}
    actions_all::Vector{ActionLineWorldStatic}
    
    function GameLineWorldBase(nstates::Int, max_jump::Int)
        state_start = StateLineWorldStatic(nstates, Int(nstates / 2))
        state = state_start
        states_all = map(i -> StateLineWorldStatic(nstates, i), 0:nstates + 1)
        actions_all = map(i -> ActionLineWorldStatic(max_jump, i), vcat(-max_jump:-1, 1:max_jump))
        new(nstates, max_jump, Ref(state), state_start, states_all, actions_all)
    end
end

state(game::GameLineWorldBase)::StateLineWorldStatic = game.state[]
state_set(game::GameLineWorldBase, state::StateLineWorldStatic) = (game.state[] = state)
nstates(game::GameLineWorldBase)::Int = game.nstates
states(game::GameLineWorldBase)::Vector{StateLineWorldStatic} = game.states_all
actions(game::GameLineWorldBase) = actions(game, state(game))
_al(game::GameLineWorldBase, state::State) = max(1, game.max_jump - state.pos + 1)
_ar(game::GameLineWorldBase, state::State) = min(length(game.actions_all), game.max_jump + nstates(game) - state.pos + 1)
actions(game::GameLineWorldBase, state::State) = @view game.actions_all[_al(game, state):_ar(game, state)]
finished(game::GameLineWorldBase) = (state(game).pos == 0) | (state(game).pos == nstates(game) + 1)
restart(game::GameLineWorldBase) = (game.state[] = game.state_start)

function update(game::GameLineWorldBase, action::ActionLineWorldStatic)::Int
    s = StateLineWorldStatic(nstates(game), state(game).pos + action.move)
    state_set(game, s)
    s.pos == 0 ? -1 : (s.pos == nstates(game) + 1 ? 1 : 0)
end
