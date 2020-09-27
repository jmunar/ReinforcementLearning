
GAME_MAX_NSTEPS = 10000

struct Game
    track::Array{Int, 2}
    prob_no_action::Float64

    episode_step::Base.RefValue{Int}
    episode_states::Array{Int, 1}
    episode_actions::Array{Int, 1}
    episode_rewards::Array{Int, 1}
    episode_restarts::Array{Bool, 1}

    cells_start::Array{Point, 1}
    state_is_winner::Array{Bool, 1}

    function Game(track::Array{Int, 2}, prob_no_action::AbstractFloat)
        episode_step = Ref(1)
        episode_states = Array{Int, 1}(undef, GAME_MAX_NSTEPS)
        episode_actions = Array{Int, 1}(undef, GAME_MAX_NSTEPS)
        episode_rewards = Array{Int, 1}(undef, GAME_MAX_NSTEPS)
        episode_restarts = falses(GAME_MAX_NSTEPS)
        cells_start = [Point(x, y) for x in 1:size(track)[2] for y in 1:size(track)[1] if track[y, x] == 2]
        cells_end = [Point(x, y) for x in 1:size(track)[2] for y in 1:size(track)[1] if track[y, x] == 3]

        state_is_winner = Array{Bool, 1}(undef, nstates(track))
        for i in 1:nstates(track)
            s = State(size(track)..., i)
            δs = cells_end - s.pos
            state_is_winner[i] = (s.speed in δs) | (length(intersect(crossings[s.speed], δs)) > 0)
        end

        new(track, prob_no_action, episode_step, episode_states, episode_actions, episode_rewards, episode_restarts, cells_start, state_is_winner)
    end

end

Game(track::Array{Int, 2}) = Game(track, 0.1)

function Base.show(io::IO, m::Game)
    print(io, "Game(nrows=", size(m.track)[1], ", ncols=", size(m.track)[2], ", Γ=", m.prob_no_action)
    if m.episode_step == 0
        print(io, ")")
    else
        print(io, ", step=", m.episode_step[], ", state=", State(size(m.track)..., m.episode_states[m.episode_step[]]), ")")
    end
end
