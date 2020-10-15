module GridWorldWindy

using ..ReinforcementLearning: Point, t

include("./Commons.jl")
include("./Game.jl")
include("./Player.jl")

function play_game_fixed_start(game::Game, player::Player, state::State)::Int

    nsteps = 0
    reward = 0
    while state.pos != game.pos_goal
        nsteps += 1

        action = decide_action(game, state, player)
        (state, action_reward) = state_update(game, state, action)
        reward += action_reward
    end

    reward
end

function play_game(game::Game, player::Player)::Int
    play_game_fixed_start(game, player, state_start(game))
end

end