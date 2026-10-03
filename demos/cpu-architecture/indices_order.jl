using BenchmarkTools
using Random

function test_benchmark()
    N = 8096
    a = rand(1:9999, N)
    b = rand(1:9999, N)
    c = similar(a)
    indices = collect(1:N)
    shuffled_indices = shuffle(indices)

    b_in_order_indices = @benchmark add_vector!($c, $a, $b, $indices)
    b_shuffled_indices = @benchmark add_vector!($c, $a, $b, $shuffled_indices)

    display(b_in_order_indices)
    display(b_shuffled_indices)

    open("demos/cpu_architecture/indices_order_results.txt", "w") do io
        show(io, MIME("text/plain"), b_in_order_indices)
        show(io, MIME("text/plain"), b_shuffled_indices)
    end
end

function add_vector!(c, a, b, indices)
    for i in indices
        c[i] = a[i] + b[i]
    end
    return c
end
