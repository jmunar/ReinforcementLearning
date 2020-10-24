
"Base type for a game"
abstract type Game end

state(game::Game) = error("To be implemented by concrete type")
state_set(game::Game, state::State) = error("To be implemented by concrete type")
states(game::Game) = error("To be implemented by concrete type")
actions(game::Game) = error("To be implemented by concrete type")
actions(game::Game, state::State) = error("To be implemented by concrete type")
finished(game::Game) = error("To be implemented by concrete type")
restart(game::Game) = error("To be implemented by concrete type")
update(game::Game, action::Action) = error("To be implemented by concrete type")
