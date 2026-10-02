# Initial conditions for the N-body simulation, plus the state and constants
# shared by every physics backend.

const G = 1.0
const SOFTENING = 0.1

mutable struct State
    pos::Matrix{Float64}    # N x 3
    vel::Matrix{Float64}    # N x 3
    mass::Vector{Float64}   # N
end

"""
One heavy body at the origin plus `n - 1` light bodies on roughly circular
orbits in the xy-plane. Returns a `State`.
"""
function rotating_disk(n; central_mass = 1000.0, inner_radius = 50.0,
                       outer_radius = 500.0, thickness = 20.0)
    pos = zeros(n, 3)
    vel = zeros(n, 3)
    mass = ones(n)
    mass[1] = central_mass

    for i in 2:n
        # sqrt(rand()) spreads bodies uniformly over the disk area
        r = inner_radius + (outer_radius - inner_radius) * sqrt(rand())
        θ = 2π * rand()
        pos[i, 1] = r * cos(θ)
        pos[i, 2] = r * sin(θ)
        pos[i, 3] = thickness * randn()

        # circular speed around the central mass, tangent to the orbit
        v = sqrt(G * central_mass / r)
        vel[i, 1] = -v * sin(θ)
        vel[i, 2] = v * cos(θ)
    end
    return State(pos, vel, mass)
end
