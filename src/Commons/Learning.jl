

abstract type Learning end

log_reward(learning::Union{Learning, Nothing}, reward::Int)::Int = nothing
log_state(learning::Union{Learning, Nothing}, state::State)::State = nothing
log_action(learning::Union{Learning, Nothing}, action::Action)::Action = nothing
log_finished_game(learning::Union{Learning, Nothing}) = nothing

abstract type LearningAlgorithmTD end

struct LearningAlgorithmSarsa <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsa, player::Player, memory::MemoryTemporalDifferences, final::Bool)
    idx_s = Q_index(player, memory.s, memory.a)
    idx_sp = Q_index(player, memory.sp, memory.ap)
    Q_final = ifelse(final, 0., player.Q[idx_sp])
    player.Q[idx_s] += algorithm.α * (memory.r + algorithm.γ * Q_final - player.Q[idx_s])
end

struct LearningAlgorithmQ <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmQ, player::Player, memory::MemoryTemporalDifferences, final::Bool)
    idx_s = Q_index(player, memory.s, memory.a)
    idx_sp = Q_index(player, memory.sp)
    Q_final = ifelse(final, 0., maximum(player.Q[idx_sp]))
    player.Q[idx_s] += algorithm.α * (memory.r + algorithm.γ * Q_final - player.Q[idx_s])
end

struct LearningAlgorithmSarsaExpected <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsaExpected, player::Player, memory::MemoryTemporalDifferences, final::Bool)
    idx_s = Q_index(player, memory.s, memory.a)
    idx_sp = Q_index(player, memory.sp)
    ps = action_probabilities(player, memory.sp)
    Q_final = 0.
    if ~final
        Q_final 
    end

    Q_final = ifelse(final, 0., sum(player.Q[idx_sp] .* ps))
    player.Q[idx_s] += algorithm.α * (memory.r + algorithm.γ * Q_final - player.Q[idx_s])
end


struct LearningTD{PlayerType<:Player, AlgorithmType<:LearningAlgorithmTD} <: Learning
    player::PlayerType
    memory::MemoryTemporalDifferences
    algorithm::AlgorithmType

    function LearningTD(player::PlayerType, algorithm::AlgorithmType) where {PlayerType<:Player, AlgorithmType<:LearningAlgorithmTD}
        new{PlayerType, AlgorithmType}(player, MemoryTemporalDifferences(), algorithm)
    end
end

log_reward(learning::LearningTD, reward::Int) = log_reward(learning.memory, reward)
log_state(learning::LearningTD, state::State) = log_state(learning.memory, state)

function log_action(learning::LearningTD, action::Action)
    log_action(learning.memory, action)

    if learning.memory.initialized
        update_policy(learning.algorithm, learning.player, learning.memory, false)
    end

    nothing
end

function log_finished_game(learning::LearningTD)
    update_policy(learning.algorithm, learning.player, learning.memory, false)
    learning.memory.initialized = false
    nothing
end

LearningSarsa(player::Player, α::Float64, γ::Float64) = LearningTD(player, LearningAlgorithmSarsa(α, γ))
LearningQ(player::Player, α::Float64, γ::Float64) = LearningTD(player, LearningAlgorithmQ(α, γ))
LearningSarsaExpected(player::Player, α::Float64, γ::Float64) = LearningTD(player, LearningAlgorithmSarsaExpected(α, γ))
