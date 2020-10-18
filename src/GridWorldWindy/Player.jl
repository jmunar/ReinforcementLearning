
abstract type Player end

function player_set_reward(player::Player, reward::Int)
    nothing
end

function player_set_state_action(player::Player, state_index::Int, action_index::Int)
    nothing
end

function player_set_finished_game(player::Player)
    nothing
end

struct PlayerDeterministic <: Player
    policy::Array{Point, 1}
end

function random_policy(game::Game)::PlayerDeterministic
    nrows, ncols = size(game.track)
    policy = [rand(actions(game, State(nrows, ncols, state_index))) for state_index in 1:nstates(nrows, ncols)]
    PlayerDeterministic(policy)
end

function decide_action(game::Game, state::State, player::PlayerDeterministic)::Point
    player.policy[index(state)]
end

struct PlayerRandom <: Player
end

function decide_action(game::Game, state::State, player::PlayerRandom)::Point
    rand(actions(game, state))
end

mutable struct MemorySarsa
    s::Int
    a::Int
    r::Int
    sp::Int
    ap::Int
    initialized::Bool

    MemorySarsa() = new(0, 0, 0, 0, 0, false)
end

struct PlayerεGreedy <: Player
    game::Game
    ε::Float64
    α::Float64
    γ::Float64
    Q::Array{Float64, 1}
    Q_lims::Array{Int, 2}
    memory::MemorySarsa

    function PlayerεGreedy(game::Game, ε::Float64, α::Float64, γ::Float64)
        actions_per_state = cumsum([nactions(game, State(game, i)) for i in 1:nstates(game)])
        Q_lims = hcat(1 .+ [0, actions_per_state[1:end-1]...], actions_per_state)
        Q = zeros(Float64, Q_lims[end])
        new(game, ε, α, γ, Q, Q_lims, MemorySarsa())
    end
end

Q_index(player::PlayerεGreedy, state_index::Int)::UnitRange = player.Q_lims[state_index, 1]:player.Q_lims[state_index, 2]
Q_index(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q_lims[state_index, 1] - 1 + action_index
Q(player::PlayerεGreedy, state_index::Int)::Array{Float64, 1} = player.Q[Q_index(player, state_index)]
Q(player::PlayerεGreedy, state_index::Int, action_index::Int)::Int = player.Q[Q_index(player, state_index, action_index)]

function player_set_reward(player::PlayerεGreedy, reward::Int)
    player.memory.r = reward
end

function player_set_state_action(player::PlayerεGreedy, state_index::Int, action_index::Int)
    m = player.memory
    m.s = m.sp
    m.a = m.ap
    m.sp = state_index
    m.ap = action_index

    if m.initialized
        idx_s = Q_index(player, m.s, m.a)
        idx_sp = Q_index(player, m.sp, m.ap)
        player.Q[idx_s] += player.α * (m.r + player.γ * player.Q[idx_sp] - player.Q[idx_s])
    else
        m.initialized = true
    end
    nothing
end

function player_set_finished_game(player::PlayerεGreedy)
    m = player.memory
    idx_s = Q_index(player, m.s, m.a)
    player.Q[idx_s] += player.α * (m.r - player.Q[idx_s])
    m.initialized = false
end

function decide_action(game::Game, state::State, player::PlayerεGreedy)::Point
    possible_actions = actions(game, state)
    state_index = index(state)

    r = rand()
    if r < player.ε
        action_index = ceil(Int, length(possible_actions) * r / player.ε)
    else
        q_here = Q(player, state_index)
        q_here_max = maximum(q_here)
        action_index = rand((1:length(possible_actions))[q_here .== q_here_max])
    end

    player_set_state_action(player, state_index, action_index)
    possible_actions[action_index]
end
