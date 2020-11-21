
abstract type Callback end

# Nothing must be done if a method is not defined by a callback 
log_state(learning::Union{Nothing, Callback}, state::Indexable) = nothing
log_action(learning::Union{Nothing, Callback}, action::Indexable) = nothing
log_reward(learning::Union{Nothing, Callback}, reward::Number) = nothing
log_state_outcome(learning::Union{Nothing, Callback}, state::Indexable) = nothing
log_finished_game(learning::Union{Nothing, Callback}) = nothing

log_state(callbacks::Tuple{Vararg{Callback}}, s::Indexable) = map(cb -> log_state(cb, s), callbacks)
log_action(callbacks::Tuple{Vararg{Callback}}, a::Indexable) = map(cb -> log_action(cb, a), callbacks)
log_reward(callbacks::Tuple{Vararg{Callback}}, r::Number) = map(cb -> log_reward(cb, r), callbacks)
log_state_outcome(callbacks::Tuple{Vararg{Callback}}, s::Indexable) = map(cb -> log_state_outcome(cb, s), callbacks)
log_finished_game(callbacks::Tuple{Vararg{Callback}}) = map(log_finished_game, callbacks)

struct Histogram <: Callback
    counts::Vector{Int}

    Histogram(nstates::Int) = new(zeros(Int, nstates))
end

log_state(hist::Histogram, state::Indexable) = (hist.counts[index(state)] += 1)
