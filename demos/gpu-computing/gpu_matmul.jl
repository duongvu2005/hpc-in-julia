using CUDA
using LinearAlgebra
using BenchmarkTools

function test_benchmark()
    N = 8192
    A = rand(Float32, N, N)
    B = rand(Float32, N, N)
    C = similar(A)

    b_cpu = @benchmark mul!($C, $A, $B)
    display(b_cpu)

    A_gpu = cu(A)
    B_gpu = cu(B)
    C_gpu = cu(C)

    b_gpu = @benchmark CUDA.@sync mul!($C_gpu, $A_gpu, $B_gpu)
    display(b_gpu)

    open("demos/gpu-computing/gpu_matmul_results.txt", "w") do io
        show(io, MIME("text/plain"), b_cpu)
        show(io, MIME("text/plain"), b_gpu)
    end
end
