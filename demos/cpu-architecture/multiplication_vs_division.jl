using BenchmarkTools

function test_benchmark()
    N = 8096
    array = rand(Float64, N)
    output = similar(array)

    b_division = @benchmark normalize_vector_div!($output, $array)
    b_multiplication = @benchmark normalize_vector_mul!($output, $array)

    display(b_division)
    display(b_multiplication)

    open("demos/cpu_architecture/multiplication_vs_division_results.txt", "w") do io
        show(io, MIME("text/plain"), b_division)
        show(io, MIME("text/plain"), b_multiplication)
    end
end

function normalize_vector_div!(output, array)
    total = sum(array)
    output .= array ./ total
end

function normalize_vector_mul!(output, array)
    inv_total = inv(sum(array))
    output .= array .* inv_total
end
