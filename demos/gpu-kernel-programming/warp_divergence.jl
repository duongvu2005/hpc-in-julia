using CUDA
using BenchmarkTools

const MAX_THREADS_PER_BLOCK = CUDA.attribute(CUDA.device(), CUDA.DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK)

function _divergent_kernel!(output, sample)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    N = length(sample)

    i > N && return nothing

    s = sample[i]
    if s > 0.5f0
        output[i] = s * s
    else
        output[i] = s / 2.8f0
    end
    nothing
end

function divergent_op!(output, sample)
    N = length(output)
    nthreads = min(N, 256)  # idk why but using 256 gives more consistant results
    nblocks = cld(N, nthreads)
    @cuda threads=nthreads blocks=nblocks _divergent_kernel!(output, sample)
    return output
end

function test_benchmark()
    N = 2^20
    sample = CUDA.rand(N)
    sample_sorted = sort(sample)
    output = similar(sample)

    b_unsorted = @benchmark CUDA.@sync divergent_op!($output, $sample)
    display(b_unsorted)

    b_sorted = @benchmark CUDA.@sync divergent_op!($output, $sample_sorted)
    display(b_sorted)

    open("demos/gpu-kernel-programming/warp_divergence_results.txt", "w") do io
        show(io, MIME("text/plain"), b_unsorted)
        show(io, MIME("text/plain"), b_sorted)
    end
end
