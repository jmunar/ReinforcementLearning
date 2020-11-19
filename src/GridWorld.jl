
"Base type for a game in the grid world. To be functional, a ruleset
must be added (see below)"
struct GameGridWorldBase{TS <: TN, TA <: TN} <: Game
    dims::TS
    state::Base.RefValue{Indexable{TS}}

    states::Vector{Indexable{TS}}
    actions::Vector{Indexable{TA}}

    function GameGridWorldBase(dims::TS, allowed_movements::Vector{TA}) where {TS <: TN, TA <: TN}
        states = [Indexable(dims, (x, y)) for y in 1:dims[2] for x in 1:dims[1]]
        actions = map(((i, m), ) -> Indexable{TA}(m, i), enumerate(allowed_movements))
        state = states[1]  # Arbitrary
        new{TS, TA}(dims, Ref(state), states, actions)
    end
end

dims(game::GameGridWorldBase) = game.dims
state(game::GameGridWorldBase) = game.state[]
state(game::GameGridWorldBase{TS, TA}, value::TS) where {TS <: TN, TA <: TN} = Indexable(dims(game), value)
state_set(game::GameGridWorldBase, state::Indexable) = begin game.state[] = state; nothing end
states(game::GameGridWorldBase) = game.states

"Base type for a game in the grid world, including ruleset
To be gunctional, the following methods must be implemented:
* actions(game, state)
* finished(game) -> bool
* restart(game)
* update(game, action) -> reward"
struct GameGridWorld{GameType <: Game, RulesetType} <: Game
    game0::GameType
    ruleset::RulesetType
end

dims(game::GameGridWorld) = dims(game.game0)
state(game::GameGridWorld) = state(game.game0)
state(game::GameGridWorld, value::TN) = state(game.game0, value)
state_set(game::GameGridWorld, state::Indexable) = state_set(game.game0, state)
states(game::GameGridWorld) = states(game.game0)
