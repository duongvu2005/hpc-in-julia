using CUDA
using CairoMakie

# 5070 Ti spec: MAX_NUM_THREADS_PER_BLOCK: 1024

function _stride_load_kernel!(out, data, stride)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if i <= length(out)
        out[i] = data[(i - 1) * stride + 1]
    end
    nothing
end

function test_benchmark()
    # data config (we use the same n_out for all strides)
    max_stride = 32
    n_out = 2^24
    data = CUDA.rand(Float32, n_out * max_stride)
    out = CUDA.zeros(Float32, n_out)
    nthreads = 256
    nblocks = cld(n_out, nthreads)

    gb_read_and_write = 2 * n_out * sizeof(eltype(data)) / 1e9
    times = Float64[]
    for stride in 1:max_stride
        launch() = @cuda threads=nthreads blocks=nblocks _stride_load_kernel!(out, data, stride)
        launch()
        t = minimum(CUDA.@elapsed(launch()) for _ in 1:20)
        gbps = gb_read_and_write / t
        println("stride $stride: $(round(Int, t * 1e6)) μs, $(round(Int, gbps)) GB/s")
        push!(times, t) 
    end

    CUDA.unsafe_free!(data)
    CUDA.unsafe_free!(out)
    
    # save results
    strides = collect(1:max_stride)
    gbps = gb_read_and_write ./ times

    fig = Figure(size=(900, 400))
    ax1 = Axis(fig[1, 1]; xlabel="stride (elements)", ylabel="time (μs)", title="Kernel time")
    ax2 = Axis(fig[1, 2]; xlabel="stride (elements)", ylabel="effective GB/s", title="Effective bandwith")
    
    barplot!(ax1, strides, times .* 1e6)
    barplot!(ax2, strides, gbps)

    save("demos/gpu-kernel-programming/mem_coalescing_results.png", fig)
end

