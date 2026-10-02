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
    cache = state.cache
    # RK4
    cache.k1x .= state.vel
    cache.k1v .= acceleration(state.pos, state.mass)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k1x
    cache.k2x .= state.vel .+ 0.5 .* dt .* cache.k1v
    cache.k2v .= acceleration(cache.tmp_pos, state.mass)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k2x
    cache.k3x .= state.vel .+ 0.5 .* dt .* cache.k2v
    cache.k3v .= acceleration(cache.tmp_pos, state.mass)

    cache.tmp_pos .= state.pos .+ dt .* cache.k3x
    cache.k4x .= state.vel .+ dt .* cache.k3v
    cache.k4v .= acceleration(cache.tmp_pos, state.mass)

    state.pos .+= (dt/6) .* (cache.k1x .+ 2 .* cache.k2x .+ 2 .* cache.k3x .+ cache.k4x)
    state.vel .+= (dt/6) .* (cache.k1v .+ 2 .* cache.k2v .+ 2 .* cache.k3v .+ cache.k4v)
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
