using CUDA
using BenchmarkTools
using Test

const MAX_THREADS_PER_BLOCK = CUDA.attribute(CUDA.device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)
function _sum_kernel!(out, numbers)
    """
    alg:
    for each block:
        [ 1,  2, 3, 5, 2, 3, 4, 1]
    ->  [ 3,  5, 7, 6, 2, 3, 4, 1]
    ->  [10, 11, 7, 6, 2, 3, 4, 1]
    ->  [21, 11, 7, 6, 2, 3, 4, 1]
    -> return 21 for that block
    -> combine result from all blocks
    """
    shared_mem = CUDA.@cuDynamicSharedMem(eltype(numbers), blockDim().x)

    N = length(numbers)
    threadId = threadIdx().x
    i = threadId + (blockIdx().x - 1) * blockDim().x

    shared_mem[threadId] = i <= N ? numbers[i] : zero(eltype(numbers))
    CUDA.sync_threads()

    num_active = blockDim().x
    while num_active > 1
        spacing = cld(num_active, 2)
        if threadId <= num_active - spacing
            shared_mem[threadId] += shared_mem[threadId + spacing]
        end
        CUDA.sync_threads()
        num_active = spacing
    end

    if threadId == 1
        CUDA.@atomic out[] += shared_mem[1]
    end
    nothing
end

function sum_gpu(numbers::CuArray)
    out = CUDA.zeros(eltype(numbers), 1)
    nthreads = min(length(numbers), MAX_THREADS_PER_BLOCK)
    nblocks = cld(length(numbers), nthreads)
    nbytes = nthreads * sizeof(eltype(numbers))
    @cuda threads=nthreads blocks=nblocks shmem=nbytes _sum_kernel!(out, numbers)
    CUDA.synchronize()
    return CUDA.@allowscalar out[1]
end

function test_benchmark()
    # test
    Ns = 1:32
    arrs = [rand(Float32, N) for N in Ns]
    for arr in arrs
        expected_sum = sum(arr)
        arr_gpu = cu(arr)
        gpu_sum_result = sum_gpu(arr_gpu)
        @test gpu_sum_result ≈ expected_sum
    end

    # benchmark
    N = 2^23

    arr = rand(Float32, N)
    arr_gpu = cu(arr)

    b_cpu = @benchmark sum($arr)
    display(b_cpu)

    b_gpu = @benchmark sum_gpu($arr_gpu)
    display(b_gpu)

    open("demos/gpu-kernel-programming/sum_results.txt", "w") do io
        show(io, MIME("text/plain"), b_cpu)
        show(io, MIME("text/plain"), b_gpu)
    end
end
