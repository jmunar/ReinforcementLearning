
module GridWorld

import ReinforcementLearningSutton.Commons: Action, Game, Point, State,
                                            actions, finished, index, nstates, restart, state, state_set, states, update

include("./State.jl")
include("./Action.jl")
include("./Game.jl")

end