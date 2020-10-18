module GridWorldWindy

using ..ReinforcementLearningSutton: Point, t

include("./Commons.jl")
include("./Game.jl")
include("./Player.jl")

function play_game_fixed_start(game::Game, player::Player, state::State)::Int

    nsteps = 0
    total_reward = 0
    while state.pos != game.pos_goal
        nsteps += 1

        action = decide_action(game, state, player)
        (reward, state) = state_update(game, state, action)
        player_set_reward(player, reward)
        total_reward += reward
    end
    player_set_finished_game(player)
    total_reward
end

function play_game(game::Game, player::Player)::Int
    play_game_fixed_start(game, player, state_start(game))
end

end