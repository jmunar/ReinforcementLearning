
struct PlayerDeterministic
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

struct PlayerRandom
end

function decide_action(game::Game, state::State, player::PlayerRandom)::Action
    rand(_AllActions)
end

struct PlayerεGreedy
    game::Game
    ε::Float64
    α::Float64
    Q::Array{Float64, 2}

    function PlayerεGreedy(game::Game, ε::Float64, α::Float64)

        nstates = nstates(nrows(game), ncols(game))
        states = [State(nrows(game), ncols(game), i) for i in 1:nstates]

        Q = zeros(Float64, nstates, nactions())

        for (s_idx, s) in enumerate(states)
            final = s.pos == game.pos_goal
            for (a_idx, a) in enumerate(_AllActions)
                if final
                    q[s_idx, a_idx] = 0.
                else
                    q[s_idx, a_idx] = 0.
                end
            end
        end
    end
end


function decide_action(game::Game, state::State, player::PlayerεGreedy)::Action
    rand(_AllActions)
end
