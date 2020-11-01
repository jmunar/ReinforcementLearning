
import Base.zero

abstract type Memory end

mutable struct MemoryRecord{RewardType}
    s::Int
    a::Int
    r::RewardType
    sp::Int
end

"Memory of last steps in game"
mutable struct MemoryLastSteps{RewardType} <: Memory
    steps::Vector{MemoryRecord{RewardType}}
    nstep::Int

    function MemoryLastSteps{RewardType}(capacity::Int) where {RewardType <: Number}
        new(map(i -> MemoryRecord(0, 0, RewardType(0), 0), 1:capacity), 0)
    end
end

capacity(memory::MemoryLastSteps) = length(memory.steps)
nstep(memory::MemoryLastSteps)::Int = memory.nstep

n2i(memory::MemoryLastSteps, n::Int)::Int = 1 + (nstep(memory) - n - 1) % capacity(memory)
n2i(memory::MemoryLastSteps) = n2i(memory, 0)
step(memory::MemoryLastSteps, n::Int)::MemoryRecord = memory.steps[n2i(memory, n)]
step(memory::MemoryLastSteps)::MemoryRecord = memory.steps[n2i(memory)]
step_random(memory::MemoryLastSteps) = rand(memory.steps[1:nstep(memory)])
restart(memory::MemoryLastSteps) = begin memory.nstep = 0 end

function state_set(memory::MemoryLastSteps, state::State)
    s = index(state)
    if nstep(memory) > 0
        memory.steps[n2i(memory)].sp = s
    end
    memory.nstep += 1
    memory.steps[n2i(memory)].s = s
    nothing
end

function action_set(memory::MemoryLastSteps, action::Action)
    memory.steps[n2i(memory)].a = index(action)
    nothing
end

function reward_set(memory::MemoryLastSteps, reward)
    memory.steps[n2i(memory)].r = reward
    nothing
end

"Memory of last steps with random selection for reviving experiences"
mutable struct MemoryDeterministic{RewardType} <: Memory
    steps::MemoryLastSteps{RewardType}
    steps_unique::MemoryLastSteps{RewardType}
    state_action_visited::Vector{Vector{Bool}}

    function MemoryDeterministic{RewardType}(nactions_per_state::Array{Int, 1}, capacity::Int = 1000) where {RewardType <: Number}
        steps = MemoryLastSteps{RewardType}(capacity)
        steps_unique = MemoryLastSteps{RewardType}(sum(nactions_per_state))
        state_action_visited = map(n -> zeros(Bool, n), nactions_per_state)
        new(steps, steps_unique, state_action_visited)
    end
end

capacity(memory::MemoryDeterministic) = capacity(memory.steps)
nstep(memory::MemoryDeterministic)::Int = nstep(memory.steps)
step(memory::MemoryDeterministic, n::Int)::MemoryRecord = step(memory.steps, n)
step(memory::MemoryDeterministic)::MemoryRecord = step(memory.steps)
restart(memory::MemoryDeterministic) = restart(memory.steps)

function state_set(memory::MemoryDeterministic, state::State)
    state_set(memory.steps, state)

    if nstep(memory) > 1
        last_step = step(memory, 1)
        s = last_step.s
        a = last_step.a
        if ~memory.state_action_visited[s][a]
            memory.state_action_visited[s][a] = true
            memory.steps_unique.nstep += 1
            memory.steps_unique.steps[memory.steps_unique.nstep] = last_step
        end
    end
    nothing
end

action_set(memory::MemoryDeterministic, action::Action) = action_set(memory.steps, action)
reward_set(memory::MemoryDeterministic, reward) = reward_set(memory.steps, reward)
