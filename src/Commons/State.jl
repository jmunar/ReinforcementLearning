"Base type for a state"
abstract type State end

index(state::State) = error("index(state) to be implemented by concrete type")
