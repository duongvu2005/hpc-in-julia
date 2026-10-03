using BenchmarkTools

function f(a, b)
    c = a * b
    d = exp(b)
    return c * d
end

function f_threads(a, b)
    c_task = Threads.@spawn a * b
    d = exp(b)
    c = fetch(c_task)
    return c * d
end

function test_benchmark()
    a = rand(8192, 512) / 1024
    b = rand(512, 512) / 1024

    b_no_threads = @benchmark f($a, $b)
    display(b_no_threads)

    b_with_threads = @benchmark f_threads($a, $b)
    display(b_with_threads)

    open("demos/multi-threading/spawning_results.txt", "w") do io
        show(io, MIME("text/plain"), b_no_threads)
        show(io, MIME("text/plain"), b_with_threads)
    end
end
