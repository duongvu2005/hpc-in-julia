using Base.Threads
using BenchmarkTools
using Test

function my_sum_atomic(numbers::Vector{Int})
    s = Atomic{Int}(0)
    @threads for n in numbers
        atomic_add!(s, n)
    end
    return s[]
end

function test_benchmark()
    N = 4096
    numbers = rand(1:99, N)

    @test my_sum_atomic(numbers) ≈ sum(numbers)

    b_atomic = @benchmark my_sum_atomic($numbers)
    display(b_atomic)
    b_normal = @benchmark sum($numbers)
    display(b_normal)

    open("demos/multi-threading/atomic_results.txt", "w") do io
        show(io, MIME("text/plain"), b_atomic)
        show(io, MIME("text/plain"), b_normal)
    end
end
