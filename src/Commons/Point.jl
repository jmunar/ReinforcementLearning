
import Base.+, Base.-

struct Point
    x::Int
    y::Int
end

Point(coords::Tuple{Int, Int}) = Point(coords...)

function Base.show(io::IO, m::Point)
  print(io, "(", m.x, ", ", m.y, ")")
end

function Base.zero(::Type{Point})
    Point(0, 0)
end

+(p1::Point, p2::Point) = Point(p1.x + p2.x, p1.y + p2.y)
-(p1::Point, p2::Point) = Point(p1.x - p2.x, p1.y - p2.y)
-(p1::Point) = Point(-p1.x, -p1.y)
t(point::Point) = Point(point.y, point.x)

+(ps::Array{Point, 1}, p0::Point) = [p1 + p0 for p1 in ps]
+(p0::Point, ps::Array{Point, 1}) = ps + p0
-(ps::Array{Point, 1}, p0::Point) = [p1 - p0 for p1 in ps]
-(p0::Point, ps::Array{Point, 1}) = [p0 - p1 for p1 in ps]
-(ps::Array{Point, 1}) = [-p1 for p1 in ps]
t(ps::Array{Point, 1}) = [t(p1) for p1 in ps]
