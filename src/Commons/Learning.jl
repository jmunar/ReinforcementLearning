
abstract type Learning end

state_set(learning::Union{Learning, Nothing}, state::State)::State = nothing
action_set(learning::Union{Learning, Nothing}, action::Action)::Action = nothing
reward_set(learning::Union{Learning, Nothing}, reward::Int)::Int = nothing
log_finished_game(learning::Union{Learning, Nothing}) = nothing

abstract type LearningAlgorithmTD end

struct LearningAlgorithmSarsa <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsa, player::Player, memory::MemoryLastSteps)
    if nstep(memory) > 1
        last_step = step(memory, 1)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        ap = step(memory).a
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * player.Q[sp][ap] - player.Q[s][a])
    end
end

struct LearningAlgorithmQ <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmQ, player::Player, memory::MemoryLastSteps)
    if nstep(memory) > 1
        last_step = step(memory, 1)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * maximum(player.Q[sp]) - player.Q[s][a])
    end
end

struct LearningAlgorithmSarsaExpected <: LearningAlgorithmTD
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmSarsaExpected, player::Player, memory::MemoryLastSteps)
    if nstep(memory) > 1
        last_step = step(memory, 1)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        ps = action_probabilities(player, s)
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * sum(player.Q[sp] .* ps) - player.Q[s][a])
    end
end


struct LearningAlgorithmDynaQ <: LearningAlgorithmTD
    n::Int
    α::Float64
    γ::Float64
end

function update_policy(algorithm::LearningAlgorithmDynaQ, player::Player, memory::MemoryDeterministic)

    if nstep(memory) > 1
        # Standard Q-learning
        last_step = step(memory, 1)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        player.Q[s][a] += algorithm.α * (r + algorithm.γ * maximum(player.Q[sp]) - player.Q[s][a])
    
        # Replay with environment model
        for i in 1:algorithm.n
            # Final states are never logged
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


function state_set(learning::LearningTD, state::State)
    update_policy(learning.algorithm, learning.player, learning.memory)
    state_set(learning.memory, state)
end
action_set(learning::LearningTD, action::Action) = action_set(learning.memory, action)
reward_set(learning::LearningTD, reward::Int) = reward_set(learning.memory, reward)

function log_finished_game(learning::LearningTD)
    restart(learning.memory)
    nothing
end

LearningSarsa(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmSarsa(α, γ))
LearningQ(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmQ(α, γ))
LearningSarsaExpected(player::Player, α::Float64, γ::Float64) = LearningTD(player, MemoryLastSteps{Int}(2), LearningAlgorithmSarsaExpected(α, γ))
LearningDynaQ(player::Player, n::Int, α::Float64, γ::Float64) = LearningTD(player, MemoryDeterministic{Int}(map(length, player.Q)), LearningAlgorithmDynaQ(n, α, γ))
