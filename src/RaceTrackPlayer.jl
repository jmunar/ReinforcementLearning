
struct PlayerDeterministic
    policy::Array{Action, 1}
end

function random_policy(track::Array{Int, 2})::PlayerDeterministic
    nrows, ncols = size(track)

    actions = [Action(i) for i in 1:nactions()]
    policy = Array{Action, 1}(undef, nstates(nrows, ncols))
    for state_index in 1:nstates(nrows, ncols)
        state = State(nrows, ncols, state_index)
        while true
            action = rand(actions)
            if action_valid(state, action)
                policy[state_index] = action
                break
            end
        end
    end

    PlayerDeterministic(policy)
end

function decide_action(game::Game, state::State, player::PlayerDeterministic)::Action
    player.policy[index(state)]
end

struct PlayerRandom
    actions::Dict{State, Array{Action,1}}

    function PlayerRandom(nrows::Int, ncols::Int)
        actions_possible = [Action(i) for i in 1:nactions()]

        actions = Dict{State, Array{Action,1}}()
        for state_index in 1:nstates(nrows, ncols)
            state = State(nrows, ncols, state_index)
            actions[state] = filter(action -> action_valid(state, action), actions_possible)
        end

        new(actions)
    end
end

function decide_action(game::Game, state::State, player::PlayerRandom)::Action
    rand(player.actions[state])
end
