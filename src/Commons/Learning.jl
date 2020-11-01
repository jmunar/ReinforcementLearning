
abstract type Learning end

state_set(learning::Union{Learning, Nothing}, state::State)::State = nothing
action_set(learning::Union{Learning, Nothing}, action::Action)::Action = nothing
reward_set(learning::Union{Learning, Nothing}, reward::Int)::Int = nothing
state_outcome_set(learning::Union{Learning, Nothing}, state::State)::State = nothing
log_finished_game(learning::Union{Learning, Nothing}) = nothing

abstract type LearningAlgorithmTD end

struct LearningAlgorithmSarsa <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsa, player::Player, memory::MemoryLastSteps, final::Bool)
    n = final ? 0 : 1
    if nstep(memory) > n
        last_step = step(memory, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        Q_update = ifelse(final, 0, player.Q[last_step.sp][step(memory).a])
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * Q_update - player.Q[s][a])
    end
end

struct LearningAlgorithmQ <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function _update_policy_qlearning(algorithm, player::Player, memory::Memory, final::Bool)
    n = final ? 0 : 1
    if nstep(memory) > n
        last_step = step(memory, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        Q_update = ifelse(final, 0, maximum(player.Q[sp]))
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * Q_update - player.Q[s][a])
    end
end

function update_policy(algorithm::LearningAlgorithmQ, player::Player, memory::MemoryLastSteps, final::Bool)
    _update_policy_qlearning(algorithm, player, memory, final)
end

struct LearningAlgorithmSarsaExpected <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsaExpected, player::Player, memory::MemoryLastSteps, final::Bool)
    n = final ? 0 : 1
    if nstep(memory) > n
        last_step = step(memory, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        Q_update = ifelse(final, 0, sum(player.Q[sp] .* action_probabilities(player, s)))
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * Q_update - player.Q[s][a])
    end
end


struct LearningAlgorithmDynaQ <: LearningAlgorithmTD
    n::Int
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmDynaQ, player::Player, memory::MemoryDeterministic, final::Bool)

    # Standard Q-learning
    _update_policy_qlearning(algorithm, player, memory, final)

    # Replay with environment model
    if nstep(memory) > 1
        for i in 1:algorithm.n
            rand_step = step_random(memory.steps_unique)
            s = rand_step.s
            a = rand_step.a
            r = rand_step.r
            sp = rand_step.sp
            player.Q[s][a] += algorithm.α * (r + algorithm.γ * maximum(player.Q[sp]) - player.Q[s][a])
        end
    end

end

struct LearningTD{PlayerType<:Player, MemoryType<:Memory, AlgorithmType<:LearningAlgorithmTD} <: Learning
    player::PlayerType
    memory::MemoryType
    algorithm::AlgorithmType
end


state_set(learning::LearningTD, state::State) = state_set(learning.memory, state)
action_set(learning::LearningTD, action::Action) = action_set(learning.memory, action)
reward_set(learning::LearningTD, reward::Int) = reward_set(learning.memory, reward)

function state_outcome_set(learning::LearningTD, state::State)
    state_outcome_set(learning.memory, state)
    update_policy(learning.algorithm, learning.player, learning.memory, false)
    nothing
end

function log_finished_game(learning::LearningTD)
    update_policy(learning.algorithm, learning.player, learning.memory, true)
    restart(learning.memory)
    nothing
end

LearningSarsa(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmSarsa(α, γ))
LearningQ(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmQ(α, γ))
LearningSarsaExpected(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmSarsaExpected(α, γ))
LearningDynaQ(player::Player, n::Int, α::Float64, γ::Float64) = LearningTD(player, MemoryDeterministic{Int}(map(length, player.Q)), LearningAlgorithmDynaQ(n, α, γ))
