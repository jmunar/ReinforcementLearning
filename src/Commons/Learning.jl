

abstract type Learning end

log_reward(learning::Union{Learning, Nothing}, reward::Int)::Int = reward
log_state(learning::Union{Learning, Nothing}, state::State)::State = state
log_action(learning::Union{Learning, Nothing}, action::Action)::Action = action
log_finished_game(learning::Union{Learning, Nothing}) = nothing

mutable struct LearningMonteCarloOffPolicy{PlayerType<:Player} <: Learning
    player::PlayerType    
end

mutable struct LearningSarsa{PlayerType<:Player} <: Learning
    player::PlayerType
    α::Float64
    γ::Float64
    s::Int
    a::Int
    r::Int
    sp::Int
    ap::Int
    initialized::Bool

    function LearningSarsa(player::PlayerType, α::Float64, γ::Float64) where {PlayerType<:Player}
        new{PlayerType}(player, α, γ, 0, 0, 0, 0, 0, false)
    end
end

function log_reward(learning::LearningSarsa, reward::Int)
    learning.r = reward
    nothing
end

function log_state(learning::LearningSarsa, state::State)
    learning.s = learning.sp
    learning.sp = index(state)
    nothing
end

function log_action(learning::LearningSarsa, action::Action)
    learning.a = learning.ap
    learning.ap = index(action)

    if learning.initialized
        player = learning.player
        idx_s = Q_index(player, learning.s, learning.a)
        idx_sp = Q_index(player, learning.sp, learning.ap)
        player.Q[idx_s] += learning.α * (learning.r + learning.γ * player.Q[idx_sp] - player.Q[idx_s])
    else
        learning.initialized = true
    end

    nothing
end

function log_finished_game(learning::LearningSarsa)
    player = learning.player
    idx_s = Q_index(player, learning.s, learning.a)
    player.Q[idx_s] += learning.α * (learning.r - player.Q[idx_s])
    learning.initialized = false
    nothing
end

mutable struct LearningQ{PlayerType<:Player} <: Learning
    player::PlayerType
    α::Float64
    γ::Float64
    s::Int
    a::Int
    r::Int
    sp::Int
    ap::Int
    initialized::Bool

    function LearningQ(player::PlayerType, α::Float64, γ::Float64) where {PlayerType<:Player}
        new{PlayerType}(player, α, γ, 0, 0, 0, 0, 0, false)
    end
end

function log_reward(learning::LearningQ, reward::Int)
    learning.r = reward
    nothing
end

function log_state(learning::LearningQ, state::State)
    learning.s = learning.sp
    learning.sp = index(state)
    nothing
end

function log_action(learning::LearningQ, action::Action)
    learning.a = learning.ap
    learning.ap = index(action)

    if learning.initialized
        player = learning.player
        idx_s = Q_index(player, learning.s, learning.a)
        idx_sp = Q_index(player, learning.sp)
        player.Q[idx_s] += learning.α * (learning.r + learning.γ * maximum(player.Q[idx_sp]) - player.Q[idx_s])
    else
        learning.initialized = true
    end

    nothing
end

function log_finished_game(learning::LearningQ)
    player = learning.player
    idx_s = Q_index(player, learning.s, learning.a)
    player.Q[idx_s] += learning.α * (learning.r - player.Q[idx_s])
    learning.initialized = false
    nothing
end
