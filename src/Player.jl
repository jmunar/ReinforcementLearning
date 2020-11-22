
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

function decide_action(player::PlayerDeterministic, state_index::Union{Int, Nothing} = nothing)::Indexable
    if state_index === nothing
        state_index = index(state(game(player)))
    end
    player.policy[state_index]
end

struct PlayerRandom{TG <: Game} <: Player
    game::TG
    nactions::Vector{Int}

    function PlayerRandom(game::TG) where {TG <: Game}
        nactions = map(s -> length(actions(game, s)), states(game))
        new{TG}(game, nactions)
    end
end

function action_probability(player::PlayerRandom, state_index::Int, action_index::Int)
    1 / player.nactions[state_index]
end

function decide_action(player::PlayerRandom, state_index::Union{Int, Nothing} = nothing)::Indexable
    options = actions(game(player), state_index)
    options[Int(ceil(length(options) * rand()))]
end

struct PlayerεGreedy{TG <: Game} <: Player
    game::TG
    ε::Float64
    Q::Vector{Vector{Float64}}
    # Avoid memory allocation using these elements
    action_probs::Vector{Float64}

    function PlayerεGreedy(game::TG, ε::Float64, Q0::Float64 = 0.) where {TG <: Game}
        Q = map(s -> fill(Q0, length(actions(game, s))), states(game))
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

function action_probability(player::PlayerεGreedy, state_index::Int, action_index::Int)
    action_probabilities(player, state_index)[action_index]
end

function decide_action(player::PlayerεGreedy, state_index::Union{Int, Nothing} = nothing)::Indexable

    if state_index === nothing
        state_index = index(state(game(player)))
    end

    ps = action_probabilities(player, state_index)

    rnd = rand()

    pcum = 0
    for (idx, p) in enumerate(ps)
        pcum += p
        if rnd < pcum
            return actions(game(player), state_index)[idx]
        end
    end

end

game(player::Union{PlayerDeterministic, PlayerRandom, PlayerεGreedy}) = player.game
