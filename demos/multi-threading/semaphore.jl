using Base.Threads
using BenchmarkTools
using Test

function my_sum_semaphore(numbers::Vector{Int})
    s_pool = Channel{Int}(nthreads())
    for _ in 1:nthreads()
        put!(s_pool, 0)
    end
    @threads for n in numbers
        s = take!(s_pool)
        s += n
        put!(s_pool, s)
    end
    s = sum(take!(s_pool) for _ in 1:nthreads())
    return s
end

function test_benchmark()
    N = 4096
    numbers = rand(1:99, N)

    @test my_sum_semaphore(numbers) ≈ sum(numbers)

    b_semaphore = @benchmark my_sum_semaphore($numbers)
    display(b_semaphore)
    b_normal = @benchmark sum($numbers)
    display(b_normal)

    open("demos/multi-threading/semaphore_results.txt", "w") do io
        show(io, MIME("text/plain"), b_semaphore)
        show(io, MIME("text/plain"), b_normal)
    end
end
