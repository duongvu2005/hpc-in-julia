using CUDA
using BenchmarkTools

const MAX_THREADS_PER_BLOCK = CUDA.attribute(CUDA.device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)

function _double_kernel!(numbers)
    N = length(numbers)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if i <= N
        numbers[i] = numbers[i] * 2
    end
    nothing
end

function double!(numbers::CuArray)
    N = length(numbers)
    nthreads = min(N, MAX_THREADS_PER_BLOCK)
    nblocks = cld(N, nthreads)
    @cuda threads=nthreads blocks=nblocks _double_kernel!(numbers)
    return numbers
end

function double!(numbers::Vector{<:Number})
    numbers .*= 2
    return numbers
end

function test_benchmark()
    N = 2^23
    
    arr = rand(Float32, N)
    arr_gpu = cu(arr)
    
    b_cpu = @benchmark double!($arr)
    display(b_cpu)

    b_gpu = @benchmark CUDA.@sync double!($arr_gpu)
    display(b_gpu)

    open("demos/gpu-kernel-programming/double_results.txt", "w") do io
        show(io, MIME("text/plain"), b_cpu)
        show(io, MIME("text/plain"), b_gpu)
    end
end
