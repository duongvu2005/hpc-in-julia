using BenchmarkTools
using Random
using Printf

# Needs to separate the modules since they contain the same function names
module Naive
include("physics_naive.jl")
end

module Symmetric
include("physics_symmetric.jl")
end

module Optimized
include("physics.jl")
end

const dt = 0.01
const IMPLEMENTATIONS = (("naive", Naive), ("symmetric", Symmetric), ("optimized", Optimized))

function make_state(implementation, n)
    Random.seed!(0)
    return implementation.rotating_disk(n)
end

function benchmark_update(implementation, n)
    state = make_state(implementation, n)
    f = implementation.update!
    return @benchmark $f($state, $dt)
end

function energy_drift(implementation, n; steps = 1000)
    state = make_state(implementation, n)
    e0 = implementation.total_energy(state)
    for _ in 1:steps
        implementation.update!(state, dt)
    end
    return abs((implementation.total_energy(state) - e0) / e0)
end

function main()
    n = 400
    @printf("--- correctness (n = %d) ---\n", n)
    @printf("%-20s %-20s\n", "implementation", "energy drift")
    for (name, implementation) in IMPLEMENTATIONS
        @printf("%-20s %-20.3e\n", name, energy_drift(implementation, n))
    end

    @printf("\n--- update! (n = %d) ---\n", n)
    for (name, implementation) in IMPLEMENTATIONS
        println("\n", name, "\n")
        b = benchmark_update(implementation, n)
        display(b)
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
