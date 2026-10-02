include("initial_conditions.jl")

"""Gravitational acceleration of every body (with softening). Returns an N x 3 matrix."""
function acceleration(pos, mass)
    N = length(mass)

    # calc distance
    x = pos[:, 1]
    y = pos[:, 2]
    z = pos[:, 3]

    dx = x' .- x
    dy = y' .- y
    dz = z' .- z

    r = sqrt.(dx.^2 .+ dy.^2 .+ dz.^2 .+ SOFTENING^2)

    # calc force & acceleration
    F = G .* (mass' .* mass) ./ r.^2

    for i in 1:N
        F[i, i] = 0
    end

    Fx = F .* dx ./ r
    Fy = F .* dy ./ r
    Fz = F .* dz ./ r

    Fx = sum(Fx, dims=2)
    Fy = sum(Fy, dims=2)
    Fz = sum(Fz, dims=2)

    a = hcat(Fx, Fy, Fz) ./ mass
    return a
end

"""Advance the state by one RK4 step of size dt."""
function update!(state::State, dt)
    # RK4
    k1x = state.vel
    k1v = acceleration(state.pos, state.mass)

    k2x = state.vel + (dt/2) * k1v
    k2v = acceleration(state.pos + (dt/2) * k1x, state.mass)

    k3x = state.vel + (dt/2) * k2v
    k3v = acceleration(state.pos + (dt/2) * k2x, state.mass)

    k4x = state.vel + dt * k3v
    k4v = acceleration(state.pos + dt * k3x, state.mass)

    state.pos += (dt/6) * (k1x + 2*k2x + 2*k3x + k4x)
    state.vel += (dt/6) * (k1v + 2*k2v + 2*k3v + k4v)
end

"""Calculate the total energy."""
function total_energy(state::State)
    kinetic = 0.5 * sum(state.mass .* (sum(abs2, state.vel, dims=2)))

    N = length(state.mass)
    
    x = state.pos[:, 1]
    y = state.pos[:, 2]
    z = state.pos[:, 3]

    dx = x' .- x
    dy = y' .- y
    dz = z' .- z

    r = sqrt.(dx.^2 .+ dy.^2 .+ dz.^2 .+ SOFTENING^2)
    V = - G * (state.mass' .* state.mass) ./ r

    for i in 1:N
        V[i, i] = 0
    end

    potential = 0.5 * sum(V)

    return kinetic + potential
end
