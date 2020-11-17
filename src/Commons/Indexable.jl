
const TN = Tuple{Vararg{Int}}

function tuple2index(dims::T, pos::T, pos0::T)::Int where {T <: TN}
    index = pos[1] - pos0[1]
    for i in 2:length(dims)
        index *= dims[i]
        index += (pos[i] - pos0[i])
    end
    index + 1
end

function tuple2index(dims::T, pos::T)::Int where {T <: TN}
    index = pos[1] - 1
    for i in 2:length(dims)
        index *= dims[i]
        index += (pos[i] - 1)
    end
    index + 1
end

struct Indexable{T <: TN}
    value::T
    index::Int
end

index(x::Indexable) = x.index

const T2 = Tuple{Int, Int}
const I2 = Indexable{T2}
