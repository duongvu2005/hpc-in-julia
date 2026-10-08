# Initial conditions for N-body simulation
const FT = Float32
const G = FT(1.0)
const ϵ2 = FT(1)
const D = 3
const dt = FT(0.01)

struct RK4Cache
    k1x::Matrix{FT}; k1v::Matrix{FT}
    k2x::Matrix{FT}; k2v::Matrix{FT}
    k3x::Matrix{FT}; k3v::Matrix{FT}
    k4x::Matrix{FT}; k4v::Matrix{FT}
    tmp_pos::Matrix{FT}
    tmp_acc::Matrix{FT}
end

mutable struct State
    pos::Matrix{FT}    # N x D
    vel::Matrix{FT}    # N x D
    mass::Vector{FT}   # N
    cache::RK4Cache
end

"""
One heavy body at the origin plus `n - 1` light bodies on roughly circular
orbits in the xy-plane. Returns a `State`.
"""
function rotating_disk(n; central_mass = 100000.0, inner_radius = 100.0, outer_radius = 1000.0, thickness = 20.0)
    pos = zeros(n, 3)
    vel = zeros(n, 3)
    mass = ones(n)
    mass[1] = central_mass

    for i in 2:n
        # spreads bodies uniformly over the disk area
        r = inner_radius + (outer_radius - inner_radius) * sqrt(rand())
        θ = 2π * rand()
        pos[i, 1] = r * cos(θ)
        pos[i, 2] = r * sin(θ)
        pos[i, 3] = thickness * randn()

        # almost circular speed around the central mass
        v = 0.8 * sqrt(G * central_mass / r)
        vel[i, 1] = -v * sin(θ)
        vel[i, 2] = v * cos(θ)
    end

    cache = RK4Cache(
        zeros(n, D), zeros(n, D),
        zeros(n, D), zeros(n, D),
        zeros(n, D), zeros(n, D),
        zeros(n, D), zeros(n, D),
        zeros(n, D),
        zeros(n, D),
    )

    return State(pos, vel, mass, cache)
end
