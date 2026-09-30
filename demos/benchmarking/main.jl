using BenchmarkTools

function test_benchmark()
    a = rand(100)
    b = rand(100)
    c = similar(a)
    display(@benchmark vector_add($a, $b))
    display(@benchmark vector_add!($c, $a, $b))
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
