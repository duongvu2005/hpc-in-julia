using BenchmarkTools

function matrix_sum_row_major(A)
    M, N = size(A)
    s = 0
    for i in 1:M
        for j in 1:N
            s += A[i, j]
        end
    end
    return s
end

function matrix_sum_column_major(A)
    M, N = size(A)
    s = 0
    for j in 1:N
        for i in 1:M
            s += A[i, j]
        end
    end
    return s
end

function test_benchmark()
    N = 10_000
    A = randn(Float32, N, N)

    println("--- Row major ---")
    b_row_major = @benchmark(matrix_sum_row_major($A))
    display(b_row_major)

    println("--- Column major ---")
    b_col_major = @benchmark(matrix_sum_column_major($A))
    display(b_col_major)
    
    open("demos/cpu_architecture/matrix_sum_results.txt", "w") do io
        show(io, MIME("text/plain"), b_row_major)
        show(io, MIME("text/plain"), b_col_major)
    end
end
