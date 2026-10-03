using BenchmarkTools

function f(x)
    return exp(-x/4) * (sin(x) + cos(3*x)/2) + 1
end

"""Calculate f(x) for each x and put into y"""
function f_loop!(y, x)
    @inbounds for i in eachindex(y)
        y[i] = f(x[i])
    end
end

"""Calculate f(x) for each x and put into y"""
function f_threads!(y, x)
    @inbounds Threads.@threads for i in eachindex(y)
        y[i] = f(x[i])
    end
end

function test_benchmark()
    N = 10^7
    y = zeros(Float64, N)
    x = LinRange(0, 10, N)

    b_no_threads = @benchmark f_loop!($y, $x)
    display(b_no_threads)

    b_with_threads = @benchmark f_threads!($y, $x)
    display(b_with_threads)

    open("demos/multi-threading/loop_results.txt", "w") do io
        show(io, MIME("text/plain"), b_no_threads)
        show(io, MIME("text/plain"), b_with_threads)
    end
end
