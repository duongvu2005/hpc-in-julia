include("initial_conditions.jl")
using StaticArrays

"""Gravitational acceleration of every body (with softening). Returns an N x 3 matrix."""
function acceleration!(tmp_acc, pos, mass, ::Val{D}) where {D}
    N = length(mass)
    tmp_acc .= 0
    @inbounds for i in 1:N
        x_i = SVector{D}(pos[k, i] for k in 1:D)
        a_i = SVector{D}(0.0 for _ in 1:D)
        m_i = mass[i]
        @simd for j in i+1:N
            x_j = SVector{D}(pos[k, j] for k in 1:D)

            x_ij = x_i - x_j
            r_ij = sqrt(sum(abs2, x_ij) + SOFTENING^2)

            scaling = G / r_ij^3
            a_ij = -scaling * mass[j] .* x_ij
            a_ji = scaling * m_i .* x_ij

            a_i += a_ij
            for k in 1:D
            # tmp_acc will store the acc of j due to all particles w/ index < j
                tmp_acc[k, j] += a_ji[k]
            end
        end
        for k in 1:D
            # adding the contribution from particles w/ index > i
            tmp_acc[k, i] += a_i[k]
        end
    end
    return tmp_acc
end

"""Advance the state by one RK4 step of size dt."""
function update!(state::State, dt)
    cache = state.cache
    dim = Val(D)
    # RK4
    cache.k1x .= state.vel
    cache.k1v .= acceleration!(cache.tmp_acc, state.pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k1x
    cache.k2x .= state.vel .+ 0.5 .* dt .* cache.k1v
    cache.k2v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k2x
    cache.k3x .= state.vel .+ 0.5 .* dt .* cache.k2v
    cache.k3v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ dt .* cache.k3x
    cache.k4x .= state.vel .+ dt .* cache.k3v
    cache.k4v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass, dim)

    state.pos .+= (dt/6) .* (cache.k1x .+ 2 .* cache.k2x .+ 2 .* cache.k3x .+ cache.k4x)
    state.vel .+= (dt/6) .* (cache.k1v .+ 2 .* cache.k2v .+ 2 .* cache.k3v .+ cache.k4v)
end

"""Calculate the total energy."""
function total_energy(state::State)
    kinetic = 0.5 * sum(state.mass .* (vec(sum(abs2, state.vel, dims=1))))

    N = length(state.mass)
    
    x = state.pos[1, :]
    y = state.pos[2, :]
    z = state.pos[3, :]

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
