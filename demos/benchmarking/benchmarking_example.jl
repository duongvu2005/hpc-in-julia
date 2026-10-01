using BenchmarkTools

function test_benchmark()
    a = rand(100)
    b = rand(100)
    c = similar(a)

    b_with_alloc = @benchmark vector_add($a, $b)
    b_without_alloc = @benchmark vector_add!($c, $a, $b)
    display(b_with_alloc)
    display(b_without_alloc)

    open("demos/benchmarking/benchmarking_example_results.txt", "w") do io
        show(io, MIME("text/plain"), b_with_alloc)
        show(io, MIME("text/plain"), b_without_alloc)
    end
end

# with alloc
function vector_add(a, b)
    c = similar(a)
    @assert length(a) == length(b)
    for i in eachindex(a, b)
        c[i] = a[i] + b[i]
    end
    return c
end

# without alloc
function vector_add!(c, a, b)
    @assert length(a) == length(b) == length(c)
    for i in eachindex(a, b)
        c[i] = a[i] + b[i]
    end
    return c
end
