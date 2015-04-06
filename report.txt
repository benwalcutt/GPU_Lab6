1. BASELINE
The code was initially designed to read in each value from the input elements and increase the histogram bin on the global memory atomically. Running with the default dimensions, this yielded the following results:
Input size:  1000000
Num of bins: 4096
Kernel time: 0.003589 seconds

This will serve as the baseline for evaluating optimizations.

2. 
DESCRIPTION: The first optimization will be to allocate local shared memory for the bins to be updated, and then update the global memory bins with the local values. This will require significantly less global memory accesses.

DIFFICULTIES: Only difficulties were in declaring the shared memory dynamically but that was resolved with a little research through notes.

OPTIMIZATION RESULTS:
Input size:  1000000
Num of bins: 4096
Kernel time: 0.000637 seconds

Improvement: 5.634x speedup

REASON: The reason behind the speed up is the decrease in global memory accesses by storing the results locally and then updating the global bins per block.

3.
DESCRIPTION: The second optimization will be to use each thread as a bin and iterate through the input, incrementing the accumulator as each number is found.

DIFFICULTIES: No difficulties in developing the optimization; other than it is useless.

OPTIMIZATION RESULTS:
Input size:  1000000
Num of bins: 4096
Kernel time: 0.081141

Improvement: 0.04423x speedup (slowdown)

REASON: The reason behind the slowdown is that the system doesn't parse the input in parallel. It does reduce the atomic operations though, but this isn't enough to overcome the fact that the runtime becomes O(4096n).
