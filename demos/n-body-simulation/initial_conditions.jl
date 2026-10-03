# Initial conditions for N-body simulation
const G = 1.0
const SOFTENING = 1e-1
const D = 3

struct RK4Cache
    k1x::Matrix{Float64}; k1v::Matrix{Float64}
    k2x::Matrix{Float64}; k2v::Matrix{Float64}
    k3x::Matrix{Float64}; k3v::Matrix{Float64}
    k4x::Matrix{Float64}; k4v::Matrix{Float64}
    tmp_pos::Matrix{Float64}
    tmp_acc::Matrix{Float64}
end

mutable struct State
    pos::Matrix{Float64}    # D x N
    vel::Matrix{Float64}    # D x N
    mass::Vector{Float64}   # N
    cache::RK4Cache
end

"""
One heavy body at the origin plus `n - 1` light bodies on roughly circular
orbits in the xy-plane. Returns a `State`.
"""
function rotating_disk(n; central_mass = 10000.0, inner_radius = 50.0, outer_radius = 500.0, thickness = 20.0)
    pos = zeros(3, n)
    vel = zeros(3, n)
    mass = ones(n)
    mass[1] = central_mass

    for i in 2:n
        # spreads bodies uniformly over the disk area
        r = inner_radius + (outer_radius - inner_radius) * sqrt(rand())
        θ = 2π * rand()
        pos[1, i] = r * cos(θ)
        pos[2, i] = r * sin(θ)
        pos[3, i] = thickness * randn()

        # almost circular speed around the central mass
        v = 0.8 * sqrt(G * central_mass / r)
        vel[1, i] = -v * sin(θ)
        vel[2, i] = v * cos(θ)
    end

    cache = RK4Cache(
        zeros(D, n), zeros(D, n),
        zeros(D, n), zeros(D, n),
        zeros(D, n), zeros(D, n),
        zeros(D, n), zeros(D, n),
        zeros(D, n),
        zeros(D, n)
    )

    return State(pos, vel, mass, cache)
end
