
mutable struct MemoryTemporalDifferences
    s::Int
    a::Int
    r::Int
    sp::Int
    ap::Int
    initialized::Bool

    MemoryTemporalDifferences() = new(0, 0, 0, 0, 0, false)
end


function log_reward(memory::MemoryTemporalDifferences, reward::Int)
    memory.r = reward
    if ~memory.initialized
        memory.initialized = true
    end
    nothing
end

function log_state(memory::MemoryTemporalDifferences, state::State)
    memory.s = memory.sp
    memory.sp = index(state)
    nothing
end

function log_action(memory::MemoryTemporalDifferences, action::Action)
    memory.a = memory.ap
    memory.ap = index(action)
    nothing
end
