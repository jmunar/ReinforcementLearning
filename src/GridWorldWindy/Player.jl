
_AllActions = [Action(i) for i in 1:nactions()]

abstract type Player end

struct PlayerDeterministic <: Player
    policy::Array{Action, 1}
end

function random_policy(game::Game)::PlayerDeterministic
    nrows, ncols = size(game.track)

    policy = [rand(_AllActions) for _ in 1:nstates(nrows, ncols)]
    PlayerDeterministic(policy)

end

function decide_action(game::Game, state::State, player::PlayerDeterministic)::Action
    player.policy[index(state)]
end

struct PlayerRandom <: Player
end

function decide_action(game::Game, state::State, player::PlayerRandom)::Action
    rand(_AllActions)
end

struct PlayerεGreedy <: Player
    game::Game
    ε::Float64
    α::Float64
    Q::Array{Float64, 2}

    function PlayerεGreedy(game::Game, ε::Float64, α::Float64)

        ns = nstates(nrows(game), ncols(game))
        states = [State(nrows(game), ncols(game), i) for i in 1:ns]

        Q = zeros(Float64, ns, nactions())

        for (s_idx, s) in enumerate(states)
            final = s.pos == game.pos_goal
            for (a_idx, a) in enumerate(_AllActions)
                if final
                    Q[s_idx, a_idx] = 0.
                else
                    Q[s_idx, a_idx] = 0.
                end
            end
        end

        new(game, ε, α, Q)
    end
end


function decide_action(game::Game, state::State, player::PlayerεGreedy)::Action
    r = rand()
    if r < player.ε
        _AllActions[ceil(Int, length(_AllActions) * r / player.ε)]
    else
        q_here = player.Q[index(state), :]
        q_here_max = maximum(q_here)
        rand(_AllActions[q_here .== q_here_max])
    end
end
