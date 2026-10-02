using BenchmarkTools

function test_benchmark()
    N = 10^6
    a = rand(Float32, N)
    b = rand(Float32, N)

    println("--- Dot Product (2 vectors) ---")
    b_dot_without_simd = @benchmark dot_product($a, $b)
    b_dot_with_simd = @benchmark dot_product_simd($a, $b)

    display(b_dot_without_simd)
    display(b_dot_with_simd)

    open("demos/cpu_architecture/simd_dot_product_results.txt", "w") do io
        show(io, MIME("text/plain"), b_dot_without_simd)
        show(io, MIME("text/plain"), b_dot_with_simd)
    end

    arr = rand(Float32, N)
    println("--- Sum (1 vector) ---")
    b_sum_without_simd = @benchmark custom_sum($arr)
    b_sum_with_simd = @benchmark custom_sum_simd($arr)

    display(b_sum_without_simd)
    display(b_sum_with_simd)

    open("demos/cpu_architecture/simd_sum_results.txt", "w") do io
        show(io, MIME("text/plain"), b_sum_without_simd)
        show(io, MIME("text/plain"), b_sum_with_simd)
    end
end

function dot_product(a, b)
    s = zero(eltype(a))
    for i in eachindex(a, b)
        s += a[i] * b[i]
    end
    return s
end

function dot_product_simd(a, b)
    s = zero(eltype(a))
    @simd for i in eachindex(a, b)
        s += a[i] * b[i]
    end
    return s
end

function custom_sum(arr)
    s = zero(eltype(arr))
    for x in arr
        s += x
    end
    return s
end

function custom_sum_simd(arr)
    s = zero(eltype(arr))
    @simd for x in arr
        s += x
    end
    return s
end
