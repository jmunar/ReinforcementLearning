
"Base type for a player
Concrete implementations must implement methods:
decide_action(player, game, state)"
abstract type Player end

struct PlayerDeterministic{T} <: Player
    policy::Array{T, 1}
end

function random_policy(game::Game)::PlayerDeterministic
    policy = map(s -> rand(actions(game, s)), states(game))
    PlayerDeterministic(policy)
end

function decide_action(player::PlayerDeterministic, game::Game)::Action
    player.policy[index(state(game))]
end

struct PlayerRandom <: Player
end

function decide_action(player::PlayerRandom, game::Game)::Action
    rand(actions(game))
end

struct PlayerεGreedy <: Player
    game::Game
    ε::Float64
    Q::Array{Float64, 1}
    Q_lims::Array{Int, 2}

    function PlayerεGreedy(game::Game, ε::Float64)
        actions_per_state = cumsum(map(s -> length(actions(game, s)), states(game)))
        Q_lims = hcat(1 .+ [0, actions_per_state[1:end-1]...], actions_per_state)
        Q = zeros(Float64, Q_lims[end])
        new(game, ε, Q, Q_lims)
    end
end

Q_index(player::PlayerεGreedy, state_index::Int)::UnitRange = player.Q_lims[state_index, 1]:player.Q_lims[state_index, 2]
Q_index(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q_lims[state_index, 1] - 1 + action_index
Q(player::PlayerεGreedy, state_index::Int)::Array{Float64, 1} = player.Q[Q_index(player, state_index)]
Q(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q[Q_index(player, state_index, action_index)]

function decide_action(player::PlayerεGreedy, game::Game)::Action
    possible_actions = actions(game)
    state_index = index(state(game))

    r = rand()
    if r < player.ε
        action_index = ceil(Int, length(possible_actions) * r / player.ε)
    else
        q_here = Q(player, state_index)
        q_here_max = maximum(q_here)
        action_index = rand((1:length(possible_actions))[q_here .== q_here_max])
    end

    possible_actions[action_index]
end
