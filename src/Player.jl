
"Base type for a player
Concrete implementations must implement methods:
game(player)
decide_action(player)"
abstract type Player end

game(player::Player) = error("game(player) to be implemented by concrete type") 
decide_action(player::Player) = error("decide_action(player) to be implemented by concrete type") 

struct PlayerDeterministic{TG <: Game, TA <: TN} <: Player
    game::TG
    policy::Vector{TA}
end

function random_policy(game::Game)::PlayerDeterministic
    policy = map(s -> rand(actions(game, s)), states(game))
    PlayerDeterministic(game, policy)
end

function decide_action(player::PlayerDeterministic)::Indexable
    player.policy[index(state(player(game)))]
end

struct PlayerRandom{TG <: Game} <: Player
    game::TG
end

function decide_action(player::PlayerRandom)::Indexable
    rand(actions(game(player)))
end

struct PlayerεGreedy{TG <: Game} <: Player
    game::TG
    ε::Float64
    Q::Vector{Vector{Float64}}
    # Avoid memory allocation using these elements
    action_probs::Vector{Float64}

    function PlayerεGreedy(game::TG, ε::Float64) where {TG <: Game}
        Q = map(s -> zeros(Float64, length(actions(game, s))), states(game))
        action_probs = Array{Float64, 1}(undef, maximum(map(length, Q)))
        new{TG}(game, ε, Q, action_probs)
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
        player.action_probs[i] = q == q_max ? pmax : pmin
    end

    @view player.action_probs[1:nactions]
end

function decide_action(player::PlayerεGreedy)::Indexable
    ps = action_probabilities(player, index(state(game(player))))
    p_sample = rand()

    pcum = 0
    for (idx, p) in enumerate(ps)
        pcum += p
        if p_sample < pcum
            return actions(game(player))[idx]
        end
    end

end

game(player::Union{PlayerDeterministic, PlayerRandom, PlayerεGreedy}) = player.game
