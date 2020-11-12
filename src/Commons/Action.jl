
"Base type for an action"
abstract type Action end

index(action::Action) = error("index(action) to be implemented by concrete type")
