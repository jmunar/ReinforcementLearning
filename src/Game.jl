
"Base type for a game"
abstract type Game end

state(game::Game) = error("state(game) to be implemented by concrete type")
state_set(game::Game, state::Indexable) = error("state_set(game, state) to be implemented by concrete type")
states(game::Game) = error("states(game) to be implemented by concrete type")
nstates(game::Game)::Int = length(states(game))
actions(game::Game, state::Indexable) = error("actions(game, state) to be implemented by concrete type")
actions(game::Game) = actions(game, state(game))
finished(game::Game) = error("finished(game) to be implemented by concrete type")
restart(game::Game) = error("restart(game) to be implemented by concrete type")
update(game::Game, action::Indexable) = error("update(game, action) to be implemented by concrete type")
