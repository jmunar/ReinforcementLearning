module Commons

include("./Point.jl")
include("./State.jl")
include("./Action.jl")
include("./Game.jl")
include("./Player.jl")
include("./Learning.jl")

function play_game(game::Game,
                   player::Player,
                   max_nrounds::Int = 10000000,
                   learning::Union{Learning, Nothing} = nothing,
                   initial_state::Union{State, Nothing} = nothing
                   )::Int

    restart(game)

    if ~(initial_state === nothing)
        state_set(game, initial_state)
    end

    nsteps = 0
    total_reward = 0
    while ~finished(game) & (nsteps < max_nrounds)
        nsteps += 1

        log_state(learning, state(game))
        action = decide_action(player, game)
        log_action(learning, action)

        reward = update(game, action)
        log_reward(learning, reward)

        total_reward += reward
    end
    log_finished_game(learning)
    total_reward
end

end