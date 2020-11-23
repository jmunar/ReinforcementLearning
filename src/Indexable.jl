
const TN = Tuple{Vararg{Int}}

function value2index(dims::T, pos::T, pos0::Union{Nothing, T} = nothing)::Int where {T <: TN}
    index = pos[1] - (pos0 === nothing ? 1 : pos0[1])
    for i in 2:length(dims)
        index *= dims[i]
        index += pos[i] - (pos0 === nothing ? 1 : pos0[i])
    end
    index + 1
end

struct Indexable{T <: TN}
    value::T
    index::Int
end

index(x::Indexable) = x.index
value(x::Indexable) = x.value

# Get Indexable object from track dimensions and current position
Indexable(dims::T, pos::T, pos0::Union{Nothing, T} = nothing) where {T <: TN} = Indexable{T}(pos, value2index(dims, pos, pos0))

function IndexableVector(dims::T, pos0::Union{Nothing, T} = nothing) where {T <: TN}
    map(idx -> Indexable(dims, reverse(Tuple(idx)) .- (pos0 === nothing ? 0 : 1 .- pos0), pos0),
        vec(CartesianIndices(reverse(dims))))
end

const T1 = Tuple{Int}
const I1 = Indexable{T1}
const T2 = Tuple{Int, Int}
const I2 = Indexable{T2}
const T3 = Tuple{Int, Int, Int}
const I3 = Indexable{T3}
const T4 = Tuple{Int, Int, Int, Int}
const I4 = Indexable{T4}
