
import Base.zero

abstract type Memory end

mutable struct MemoryRecordTemp{RewardType <: Number}
    s::Int
    a::Int
    r::RewardType
    sp::Int
end

struct MemoryRecord{RewardType <: Number}
    s::Int
    a::Int
    r::RewardType
    sp::Int
end

MemoryRecord(r::MemoryRecordTemp) = MemoryRecord(r.s, r.a, r.r, r.sp)

"Memory of last steps in game"
struct MemoryLastSteps{RewardType} <: Memory
    steps::Vector{MemoryRecord{RewardType}}
    nstep::Base.RefValue{Int}
    step_temp::MemoryRecordTemp{RewardType}

    function MemoryLastSteps{RewardType}(capacity::Int) where {RewardType <: Number}
        new(map(i -> MemoryRecord(0, 0, RewardType(0), 0), 1:capacity), Ref(0), MemoryRecordTemp(0, 0, RewardType(0), 0))
    end
end

capacity(memory::MemoryLastSteps) = length(memory.steps)
nstep(memory::MemoryLastSteps)::Int = memory.nstep[]

n2i(memory::MemoryLastSteps, n::Int)::Int = 1 + (nstep(memory) - n - 1) % capacity(memory)
n2i(memory::MemoryLastSteps)::Int = n2i(memory, 0)
step(memory::MemoryLastSteps, n::Int)::MemoryRecord = memory.steps[n2i(memory, n)]
step(memory::MemoryLastSteps)::MemoryRecord = memory.steps[n2i(memory)]
step_random(memory::MemoryLastSteps)::MemoryRecord = rand(memory.steps[1:nstep(memory)])
restart(memory::MemoryLastSteps) = begin memory.nstep[] = 0 end

function log_state(memory::MemoryLastSteps, state::State)
    memory.nstep[] += 1
    memory.step_temp.s = index(state)
    nothing
end

function log_action(memory::MemoryLastSteps, action::Action)
    memory.step_temp.a = index(action)
    nothing
end

function log_reward(memory::MemoryLastSteps, reward)
    memory.step_temp.r = reward
    nothing
end

function log_state_outcome(memory::MemoryLastSteps, state::State)
    memory.step_temp.sp = index(state)
    memory.steps[n2i(memory)] = MemoryRecord(memory.step_temp)
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


log_state(memory::MemoryDeterministic, state::State) = log_state(memory.steps, state)
log_action(memory::MemoryDeterministic, action::Action) = log_action(memory.steps, action)
log_reward(memory::MemoryDeterministic, reward) = log_reward(memory.steps, reward)

function log_state_outcome(memory::MemoryDeterministic, state::State)
    log_state_outcome(memory.steps, state)
    last_step = step(memory)
    s = last_step.s
    a = last_step.a
    if ~memory.state_action_visited[s][a]
        memory.state_action_visited[s][a] = true
        memory.steps_unique.nstep += 1
        memory.steps_unique.steps[memory.steps_unique.nstep] = last_step
    end
    nothing
end
