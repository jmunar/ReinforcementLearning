
module ReinforcementLearningSutton

include("./Indexable.jl")
include("./Callback.jl")
include("./Game.jl")
include("./Player.jl")
include("./Memory.jl")
include("./Learning.jl")

# Non-core packages
include("./GridWorld.jl")

function play_game(game::Game,
                   player::Player,
                   max_nsteps::Int = 10000000,
                   callbacks::Union{Callback, Tuple{Vararg{Callback}}, Nothing} = nothing,
                   initial_state::Union{Indexable, Nothing} = nothing
                   )::Tuple{Int, Int}

    restart(game)

    if ~(initial_state === nothing)
        state_set(game, initial_state)
    end

    nsteps = 0
    total_reward = 0
    while ~finished(game) && (nsteps < max_nsteps)
        nsteps += 1

        log_state(callbacks, state(game))
        action = decide_action(player)
        log_action(callbacks, action)

        reward = update(game, action)
        log_reward(callbacks, reward)
        total_reward += reward

        log_state_outcome(callbacks, state(game))
    end

    log_finished_game(callbacks)

    return nsteps, total_reward
end

end
