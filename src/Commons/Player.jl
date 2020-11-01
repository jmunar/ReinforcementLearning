
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
    Q::Array{Array{Float64, 1}, 1}
    # Avoid memory allocation using these elements
    action_probs::Array{Float64, 1}

    function PlayerεGreedy(game::Game, ε::Float64)
        Q = map(s -> zeros(Float64, length(actions(game, s))), states(game))
        action_probs = Array{Float64, 1}(undef, maximum(map(length, Q)))
        new(game, ε, Q, action_probs)
    end
end

function action_probabilities(player::PlayerεGreedy, state_index::Int)

    qs = player.Q[state_index]
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
