
abstract type Learning end

# Set default actions whenever there is no learning involved
state_set(learning::Nothing, state::State) = nothing
action_set(learning::Nothing, action::Action) = nothing
reward_set(learning::Nothing, reward::Int) = nothing
state_outcome_set(learning::Nothing, state::State) = nothing
log_finished_game(learning::Nothing) = nothing

memory(learning::Learning) = error("To be implemented by concrete type")
player(learning::Learning) = error("To be implemented by concrete type")
update_policy(learning::Learning, final::Bool) = error("To be implemented by concrete type")

state_set(learning::Learning, state::State) = state_set(memory(learning), state)
action_set(learning::Learning, action::Action) = action_set(memory(learning), action)
reward_set(learning::Learning, reward::Int) = reward_set(memory(learning), reward)

function state_outcome_set(learning::Learning, state::State)
    state_outcome_set(memory(learning), state)
    update_policy(learning, false)
    nothing
end

function log_finished_game(learning::Learning)
    update_policy(learning, true)
    restart(memory(learning))
    nothing
end

struct LearningSarsa{PlayerType <: Player} <: Learning
    player::PlayerType
    memory::MemoryLastSteps{Int}
    α::Float64
    γ::Float64

    LearningSarsa(player::T, α::Float64, γ::Float64) where {T <: Player} = new{T}(player, MemoryLastSteps{Int}(2), α, γ)
end

function update_policy(learning::LearningSarsa, final::Bool)
    play, mem = player(learning), memory(learning)
    n = final ? 0 : 1
    if nstep(mem) > n
        last_step = step(mem, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        Q_update = ifelse(final, 0, play.Q[last_step.sp][step(mem).a])
        play.Q[s][a] += learning.α * (r + learning.γ * Q_update - play.Q[s][a])
    end
end

struct LearningQ{PlayerType <: Player} <: Learning
    player::PlayerType
    memory::MemoryLastSteps{Int}
    α::Float64
    γ::Float64

    LearningQ(player::T, α::Float64, γ::Float64) where {T <: Player} = new{T}(player, MemoryLastSteps{Int}(2), α, γ)
end

function _update_policy_qlearning(player::Player, mem::Memory, α::Float64, γ::Float64, final::Bool)
    n = final ? 0 : 1
    if nstep(mem) > n
        last_step = step(mem, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        Q_update = ifelse(final, 0, maximum(player.Q[sp]))
        player.Q[s][a] += α * (r + γ * Q_update - player.Q[s][a])
    end
end

function update_policy(learning::LearningQ, final::Bool)
    _update_policy_qlearning(player(learning), memory(learning), learning.α, learning.γ, final)
end

struct LearningSarsaExpected{PlayerType <: Player} <: Learning
    player::PlayerType
    memory::MemoryLastSteps{Int}
    α::Float64
    γ::Float64

    LearningSarsaExpected(player::T, α::Float64, γ::Float64) where {T <: Player} = new{T}(player, MemoryLastSteps{Int}(2), α, γ)
end

function update_policy(learning::LearningSarsaExpected, final::Bool)
    play, mem = player(learning), memory(learning)
    n = final ? 0 : 1
    if nstep(mem) > n
        last_step = step(mem, n)
        s = last_step.s
        a = last_step.a
        r = last_step.r
        sp = last_step.sp
        Q_update = ifelse(final, 0, sum(play.Q[sp] .* action_probabilities(play, s)))
        play.Q[s][a] += learning.α * (r + learning.γ * Q_update - play.Q[s][a])
    end
end

struct LearningDynaQ{PlayerType <: Player} <: Learning
    player::PlayerType
    memory::MemoryLastSteps{Int}
    n::Int
    α::Float64
    γ::Float64

    LearningDynaQ(player::T, n::Int, α::Float64, γ::Float64) where {T <: Player} = new{T}(player, MemoryDeterministic{Int}(map(length, player.Q)), n, α, γ)
end

function update_policy(learning::LearningDynaQ, final::Bool)
    play, mem = player(learning), memory(learning)

    # Standard Q-learning
    _update_policy_qlearning(play, mem, learning.α, learning.γ, final)

    # Replay with environment model
    if nstep(mem) > 1
        for i in 1:learning.n
            rand_step = step_random(mem.steps_unique)
            s = rand_step.s
            a = rand_step.a
            r = rand_step.r
            sp = rand_step.sp
            play.Q[s][a] += learning.α * (r + learning.γ * maximum(play.Q[sp]) - play.Q[s][a])
        end
    end

end

player(learning::Union{LearningSarsa, LearningQ, LearningSarsaExpected, LearningDynaQ}) = learning.player
memory(learning::Union{LearningSarsa, LearningQ, LearningSarsaExpected, LearningDynaQ}) = learning.memory
