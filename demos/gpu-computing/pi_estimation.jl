using CUDA
using BenchmarkTools
using Test

# estimating π by throwing darts

function throw_dart()
    # r = 1
    x = rand() * 2 - 1
    y = rand() * 2 - 1
    return (x^2 + y^2 <= 1)
end

function estimate_pi(N)
    hits = mapreduce(_->throw_dart(), +, 1:N)
    return 4 * hits / N
end

function estimate_pi_gpu(N)
    darts = CuArray{Bool}(undef, N)
    darts .= (_->throw_dart()).(nothing)
    estimate = 4 * reduce(+, darts, init=0) / N
    CUDA.unsafe_free!(darts)
    return estimate
end

function test_benchmark()
    N = 2^26

    @test isapprox(estimate_pi(N), π, atol=0.001)
    @test isapprox(estimate_pi_gpu(N), π, atol=0.001)

    b_cpu = @benchmark estimate_pi($N)
    display(b_cpu)

    b_gpu = @benchmark CUDA.@sync estimate_pi_gpu($N)
    display(b_gpu)

    open("demos/gpu-computing/pi_estimation_results.txt", "w") do io
        show(io, MIME("text/plain"), b_cpu)
        show(io, MIME("text/plain"), b_gpu)
    end
end
