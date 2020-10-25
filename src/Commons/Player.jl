
using StatsBase: sample, Weights

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

function action_probabilities(player::PlayerεGreedy, state_index::Int)::Array{Float64, 1}

    q_here = Q(player, state_index)
    q_here_is_max = q_here .== maximum(q_here)
    nmax = sum(q_here_is_max)

    ε = player.ε
    nactions = length(q_here)
    pmax = (1 - ε) / nmax + ε / nactions
    pmin = ε / nactions
    map(is_max -> ifelse(is_max, pmax, pmin), q_here_is_max)
end

function decide_action(player::PlayerεGreedy, game::Game)::Action
    sample(actions(game), Weights(action_probabilities(player, index(state(game)))))
end
