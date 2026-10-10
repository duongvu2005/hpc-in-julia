using CUDA
using Random
using BenchmarkTools

function random_walk(T)
    x = Int32(0)
    for _ in 1:T
        x += (rand(Float32) < 0.5f0) * Int32(2) - Int32(1)
    end
    return x
end

function walks(N, T)
    walks = Vector{Int32}(undef, N)
    walks .= random_walk.(T)
    return walks
end

function walks_gpu(N, T)
    walks = CuArray{Int32}(undef, N)
    walks .= random_walk.(T)
    return walks
end

function test_benchmark()
    N = 8192
    T = 100
    
    b_cpu = @benchmark walks($N, $T)
    display(b_cpu)

    b_gpu = @benchmark CUDA.@sync walks_gpu($N, $T)
    display(b_gpu)

    open("demos/gpu-computing/parallel-simu-results.txt", "w") do io
        show(io, MIME("text/plain"), b_cpu)
        show(io, MIME("text/plain"), b_gpu)
    end
end
