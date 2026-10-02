using BenchmarkTools
using Random
using Printf

# Each backend gets its own module, since both define acceleration / update! / State.
module Naive
include("physics-naive.jl")
end

module Optimized
include("physics.jl")
end

const dt = 0.01
const BACKENDS = (("naive", Naive), ("physics", Optimized))

# Same seed, so every backend starts from the same initial state
function make_state(backend, n)
    Random.seed!(0)
    return backend.rotating_disk(n)
end

function benchmark_update(backend, n)
    state = make_state(backend, n)
    return @benchmark $backend.update!($state, $dt)
end

function energy_drift(backend, n; steps = 1000)
    state = make_state(backend, n)
    e0 = backend.total_energy(state)
    for _ in 1:steps
        backend.update!(state, dt)
    end
    return abs((backend.total_energy(state) - e0) / e0)
end

# Largest position difference from the naive backend after `steps` steps.
# An optimization should keep this at roundoff level.
function max_deviation(backend, n; steps = 100)
    reference = make_state(Naive, n)
    state = make_state(backend, n)
    for _ in 1:steps
        Naive.update!(reference, dt)
        backend.update!(state, dt)
    end
    return maximum(abs.(state.pos .- reference.pos))
end

function main()
    println("--- correctness (n = 100) ---")
    @printf("%-10s %-20s %-20s\n", "backend", "energy drift", "max |pos - naive|")
    for (name, backend) in BACKENDS
        @printf("%-10s %-20.3e %-20.3e\n", name, energy_drift(backend, 100),
                max_deviation(backend, 100))
    end

    println("\n--- update! (median) ---")
    @printf("%-6s %-10s %-12s %-12s %-12s %-8s\n", "n", "backend", "time", "memory", "allocs", "speedup")
    for n in (50, 100, 200, 400)
        base = nothing
        for (name, backend) in BACKENDS
            trial = benchmark_update(backend, n)
            t = median(trial).time
            base === nothing && (base = t)
            @printf("%-6d %-10s %-12s %-12s %-12d %-8.2f\n", n, name,
                    BenchmarkTools.prettytime(t), BenchmarkTools.prettymemory(trial.memory),
                    trial.allocs, base / t)
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
