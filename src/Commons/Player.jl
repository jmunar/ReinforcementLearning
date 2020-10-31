
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
    # Avoid memory allocation using these elements
    action_probs::Array{Float64, 1}

    function PlayerεGreedy(game::Game, ε::Float64)
        actions_per_state = cumsum(map(s -> length(actions(game, s)), states(game)))
        Q_lims = hcat(1 .+ [0, actions_per_state[1:end-1]...], actions_per_state)
        Q = zeros(Float64, Q_lims[end])
        action_probs = Array{Float64, 1}(undef, maximum(actions_per_state))
        new(game, ε, Q, Q_lims, action_probs)
    end
end

Q_index(player::PlayerεGreedy, state_index::Int)::UnitRange = player.Q_lims[state_index, 1]:player.Q_lims[state_index, 2]
Q_index(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q_lims[state_index, 1] - 1 + action_index
Q(player::PlayerεGreedy, state_index::Int) = @view player.Q[Q_index(player, state_index)]
Q(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q[Q_index(player, state_index, action_index)]

function action_probabilities(player::PlayerεGreedy, state_index::Int)

    qs = Q(player, state_index)
    nactions = length(qs)

    q_max = 0.
    nmax = 0
    for (i, q) in enumerate(qs)
        if i == 1 || q > q_max
            q_max = q
            nmax = 1
        elseif q == q_max
            nmax += 1
        end
    end
        
    ε = player.ε
    pmax = (1 - ε) / nmax + ε / nactions
    pmin = ε / nactions
    for (i, q) in enumerate(qs)
        player.action_probs[i] = ifelse(q == q_max, pmax, pmin)
    end

    @view player.action_probs[1:nactions]
end

function decide_action(player::PlayerεGreedy, game::Game)::Action
    ps = action_probabilities(player, index(state(game)))
    p_sample = rand()

    pcum = 0
    for (idx, p) in enumerate(ps)
        pcum += p
        if p_sample < pcum
            return actions(game)[idx]
        end
    end

end
