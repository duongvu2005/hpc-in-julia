# Optimizing the N-body simulation

Original median time to compute an update with `n = 400` particles before any optimization
is roughly 5.730ms. We will try to push this number to as low as possible until the point
where we can comfortably simulate `10_000` particles.

## Heap Allocations

Heap allocation -> Garbage collection during the simulation, which slows it down.
Plan: initialize the arrays and fill in the values instead (preallocation).

We will use the modified State with the cache appended.

```julia
struct RK4Cache
    k1x::Matrix{Float64}; k1v::Matrix{Float64}
    k2x::Matrix{Float64}; k2v::Matrix{Float64}
    k3x::Matrix{Float64}; k3v::Matrix{Float64}
    k4x::Matrix{Float64}; k4v::Matrix{Float64}
    tmp_pos::Matrix{Float64}
    tmp_acc::Matrix{Float64}
end
```

Using this, the RK4 function turns into something like following

```julia
function update!(state::State, dt)
    cache = state.cache
    # RK4
    cache.k1x .= state.vel
    cache.k1v .= acceleration!(cache.tmp_acc, state.pos, state.mass)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k1x
    cache.k2x .= state.vel .+ 0.5 .* dt .* cache.k1v
    cache.k2v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass)

    cache.tmp_pos .= state.pos .+ 0.5 .* dt .* cache.k2x
    cache.k3x .= state.vel .+ 0.5 .* dt .* cache.k2v
    cache.k3v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass)

    cache.tmp_pos .= state.pos .+ dt .* cache.k3x
    cache.k4x .= state.vel .+ dt .* cache.k3v
    cache.k4v .= acceleration!(cache.tmp_acc, cache.tmp_pos, state.mass)

    state.pos .+= (dt/6) .* (cache.k1x .+ 2 .* cache.k2x .+ 2 .* cache.k3x .+ cache.k4x)
    state.vel .+= (dt/6) .* (cache.k1v .+ 2 .* cache.k2v .+ 2 .* cache.k3v .+ cache.k4v)
end
```

and the acceleration function turns into this

```julia
function acceleration!(tmp_acc, pos, mass)
    N, D = size(pos)
    tmp_acc .= 0.0
    for i in 1:N
        x_i = @SVector [pos[i, k] for k in 1:3]
        for j in 1:N
            if i == j
                continue
            end
            x_j = @SVector [pos[j, k] for k in 1:3]

            x_ij = x_i - x_j
            r_ij = sqrt(sum(abs2, x_ij) + SOFTENING^2)

            a_ij = (-G * mass[j] / r_ij^3) .* x_ij
            for k in 1:D
                tmp_acc[i, k] += a_ij[k]
            end
        end
    end
    return tmp_acc
end
```

At this point, we have successfully removed all heap allocations.

## Row major vs Column major

Julia is column major, so maybe changing the matrices to be 3xN instead of Nx3 will speed
up the code a little bit (see [row major vs column major](../cpu-architecture/matrix_sum_results.txt))

Well... I did it and got a 0.008ms (from 1.504ms to 1.496ms, or 0.53%) speed up... I hope it's worth
it for the `N = 10_000` simulation lmfao (and that it's not just pure noise).

## Reading from memory

Recall that reading from memory is one of the expensive operations (see the
[cpu operation cost chart](../cpu-architecture/cpu_operations_cost.png)).
Thus, we will read and write to the `tmp_acc` as infrequent as possible by moving it out of the `j` loop.
To do so, we need to create a static array to store the acceleration. Doing this actually improved the
performance for like 0.087ms (from 1.496ms to 1.409ms, or 5.8%).

## Redundant computations

### Inbound checks

We don't need to check that our indices are in bound here, so we can add `@inbounds` to our loop.

### Newton's 3rd law

We only need to compute half of the `N x N` matrix, so the inner loop can go from `i+1:N` instead.

---

Doing both of these optimizations, the performance improved for about 0.329ms (from 1.409ms to 1.080ms,
or 23.3%).

## Static type

We declare the dimension D using a value type so the compiler have access to the number of dimension at
compile time and can use this information to optimize our code (also, we won't have to hard-code the
number of dimension into our code, which is nice).

Doing so, we got a 0.145ms improvement (from 1.080ms to 0.935ms, or 13.5% improvement).

## simd

As a baseline, adding `@simd` in our `j` loop gives us a 0.09ms improvement (from 0.935ms to 0.845ms,
or 9.5% improvement). With `@turbo` the time was 0.884ms which is worse than `@simd` for whatever
reason so I don't think it's worth messing our code over that.

Actually, this is evidence that while using Newton's 3rd law saves us some computation, the simulation
itself will scale badly because the loops now are not independent of each other. To make this scale
even better, we will bring back the full `1:N` `i` and `j` loops.

## Vectorization and Multithreading

Motivated by the section above, we reinstate the `1:N` loop for both. The acceleration function is now

```julia
"""Gravitational acceleration of every body (with softening). Returns an N x 3 matrix."""
function acceleration!(tmp_acc, pos, mass, ::Val{D}) where {D}
    N = length(mass)
    ϵ2 = SOFTENING^2
    @inbounds for i in 1:N
        x_i = SVector{D}(pos[k, i] for k in 1:D)
        a_i = SVector{D}(0.0 for _ in 1:D)
        @simd for j in 1:N
            x_j = SVector{D}(pos[k, j] for k in 1:D)

            x_ij = x_i - x_j
            r_ij = sqrt(sum(abs2, x_ij) + SOFTENING^2)

            a_i += -G / r_ij^3 * mass[j] .* x_ij
        end
        for k in 1:D
            tmp_acc[k, i] = a_i[k]
        end
    end
    return tmp_acc
end
```

In fact, after doing this, we gain a massive boost in performance. The median time dropped by a massive
0.333ms (from 0.845ms to 0.512ms, or 39.4%) improvement.
