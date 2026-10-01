using BenchmarkTools

# Theoretically should work but the Julia compiler unwraps the 1st one
# into the second one anyway so we'll see no difference...

function test_benchmark()
    N = 1024
    arr = rand(1:100, N)
    arr_sorted = sort(arr)

    println("--- Random Data ---")
    # expect a lot of branch misprediction
    b_branching_random = @benchmark count_branching($arr)
    b_branchless_random = @benchmark count_branchless($arr)

    display(b_branching_random)
    display(b_branchless_random)

    println("--- Sorted Data ---")
    # better branch prediction
    b_branching_sorted = @benchmark count_branching($arr_sorted)
    b_branchless_sorted = @benchmark count_branchless($arr_sorted)
    
    display(b_branching_sorted)
    display(b_branchless_sorted)
end

function count_branching(arr)
    count = 0
    for x in arr
        if x > 50
            count += 1
        end
    end
    return count
end

function count_branchless(arr)
    count = 0
    for x in arr
        count += x > 50
    end
    return count
end
