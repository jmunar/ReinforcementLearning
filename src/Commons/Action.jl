
"Base type for an action"
abstract type Action end

index(action::Action) = error("To be implemented by concrete type")
