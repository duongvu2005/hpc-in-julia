using Base.Threads
using BenchmarkTools
using Test

function my_sum_mutex(numbers::Vector{Int})
    s = 0
    lk = ReentrantLock()
    @threads for n in numbers
        lock(lk) do
            s += n
        end
    end
    return s
end

function test_benchmark()
    N = 4096
    numbers = rand(1:99, N)

    @test my_sum_mutex(numbers) ≈ sum(numbers)

    b_mutex = @benchmark my_sum_mutex($numbers)
    display(b_mutex)
    b_normal = @benchmark sum($numbers)
    display(b_normal)

    open("demos/multi-threading/mutex_results.txt", "w") do io
        show(io, MIME("text/plain"), b_mutex)
        show(io, MIME("text/plain"), b_normal)
    end
end
