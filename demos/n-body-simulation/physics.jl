include("initial_conditions.jl")
using StaticArrays

@inline function body_acceleration(pos::AbstractMatrix{T}, mass, i, ::Val{D}) where {T, D}
    x_i = SVector{D}(pos[i, k] for k in 1:D)
    a_i = zero(SVector{D, T})
    @inbounds @simd for j in eachindex(mass)
        x_j = SVector{D}(pos[j, k] for k in 1:D)
        x_ij = x_i - x_j
        inv_r_ij = 1 / sqrt(sum(abs2, x_ij) + ϵ2)
        a_i += -inv_r_ij^3 * mass[j] .* x_ij
    end
    return G * a_i
end

"""Gravitational acceleration of every body (with softening). Returns an N x 3 matrix."""
function acceleration!(kv_cache, pos, mass, dim::Val{D}) where {D}
    N = length(mass)
    @inbounds Threads.@threads for i in 1:N
        a_i = body_acceleration(pos, mass, i, dim)
        for k in 1:D
            kv_cache[i, k] = a_i[k]
        end
    end
    return kv_cache
end

"""Advance the state by one RK4 step of size dt."""
function update!(state::State, dt)
    cache = state.cache
    dim = Val(D)
    # RK4
    cache.k1x .= state.vel
    acceleration!(cache.k1v, state.pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ (dt/2) .* cache.k1x
    cache.k2x .= state.vel .+ (dt/2) .* cache.k1v
    acceleration!(cache.k2v, cache.tmp_pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ (dt/2) .* cache.k2x
    cache.k3x .= state.vel .+ (dt/2) .* cache.k2v
    acceleration!(cache.k3v, cache.tmp_pos, state.mass, dim)

    cache.tmp_pos .= state.pos .+ dt .* cache.k3x
    cache.k4x .= state.vel .+ dt .* cache.k3v
    acceleration!(cache.k4v, cache.tmp_pos, state.mass, dim)

    state.pos .+= (dt/6) .* (cache.k1x .+ 2 .* cache.k2x .+ 2 .* cache.k3x .+ cache.k4x)
    state.vel .+= (dt/6) .* (cache.k1v .+ 2 .* cache.k2v .+ 2 .* cache.k3v .+ cache.k4v)
end

"""Calculate the total energy."""
function total_energy(state::State)
    N = length(state.mass)

    kinetic = 0.0
    potential = 0.0
    @inbounds for i in 1:N
        m_i = state.mass[i]
        v_i = SVector{D}(state.vel[i, k] for k in 1:D)
        kinetic += m_i * sum(abs2, v_i)

        x_i = SVector{D}(state.pos[i, k] for k in 1:D)
        @simd for j in i+1:N
            x_j = SVector{D}(state.pos[j, k] for k in 1:D)
            potential -= m_i * state.mass[j] / sqrt(sum(abs2, x_i - x_j) + ϵ2)
        end
    end
    return kinetic / 2 + G * potential
end
