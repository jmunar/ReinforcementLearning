module RaceTrack

using ..ReinforcementLearning: Point, t

include("./Commons.jl")
include("./Game.jl")
include("./Player.jl")

function play_game_fixed_start(game::Game, player::Union{PlayerDeterministic, PlayerRandom}, state::State)::Int

    game.episode_step[] = 0

    while true
        game.episode_step[] += 1
        game.episode_states[game.episode_step[]] = index(state)

        action = decide_action(game, state, player)
        game.episode_actions[game.episode_step[]] = index(action)

        game.episode_rewards[game.episode_step[]] = -1

        if (game.prob_no_action > 0) & (rand() < game.prob_no_action)
            action = Action(Point(0, 0))
        end

        # Update speed to check if the movement is a winner one
        speed = state.speed + action.acc
        state = State(state.nrows, state.ncols, state.pos, speed)

        if game.state_is_winner[index(state)]
            break
        end

        # Update game state
        pos = state.pos + speed
        state = State(state.nrows, state.ncols, pos, speed)

        # Reset game if we are outside the track
        game.episode_restarts[game.episode_step[]] = !state.valid
        if !state.valid
            pos = rand(game.cells_start)
            speed = Point(0, 0)
            state = State(state.nrows, state.ncols, pos, speed)
        end

    end

    return game.episode_step[]

end

function play_game(game::Game, player::Union{PlayerDeterministic, PlayerRandom})::Int
    state = State(size(game.track)..., rand(game.cells_start), Point(0, 0))
    return play_game_fixed_start(game, player, state)
end

end
