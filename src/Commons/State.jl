"Base type for a state"
abstract type State end

index(state::State) = error("To be implemented by concrete type")
