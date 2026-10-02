# Optimizing the N-body simulation

## Heap Allocations

Heap allocation -> Garbage collection during the simulation, which slows it down.
Plan: initialize the arrays and fill in the values instead (preallocation).

We will use the modified State with the cache appended.
