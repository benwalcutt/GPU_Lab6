/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

// Define your kernels in this file you may use more than one kernel if you
// need to

#define BLOCK_SIZE 512
#define NUM_BLOCKS 30
#define OFFSET (BLOCK_SIZE * NUM_BLOCKS)

// INSERT KERNEL(S) HERE

__global__ void histogram_kernel(unsigned int* input, unsigned int* bins,
    unsigned int num_elements, unsigned int num_bins) {
		
	int globalId = blockIdx.x * BLOCK_SIZE + threadIdx.x;
	unsigned int temp;
	
	// determine how many times are assigned grid is supposed to run
	int iterations = num_elements / (BLOCK_SIZE * NUM_BLOCKS) + 1;
	
	for (int i = 0; i < iterations; i++) {
		if (globalId + (OFFSET * i) < num_elements) {
			temp = input[globalId + (OFFSET * i)];
			temp = atomicAdd(&bins[temp], 1u);
		}
	}
	
}

__global__ void convert_kernel(unsigned int *bins32, uint8_t *bins8,
    unsigned int num_bins) {

	int globalId = blockIdx.x * BLOCK_SIZE + threadIdx.x;
	
	bins8[globalId] = (bins32[globalId] > 255) ? 255 : bins32[globalId];




}

/******************************************************************************
Setup and invoke your kernel(s) in this function. You may also allocate more
GPU memory if you need to
*******************************************************************************/
void histogram(unsigned int* input, uint8_t* bins, unsigned int num_elements,
        unsigned int num_bins) {

    

    // Create 32 bit bins
    unsigned int *bins32;
    cudaMalloc((void**)&bins32, num_bins * sizeof(unsigned int));
    cudaMemset(bins32, 0, num_bins * sizeof(unsigned int));

    // Launch histogram kernel using 32-bit bins
    dim3 dim_grid, dim_block;
    dim_block.x = 512; dim_block.y = dim_block.z = 1;
    dim_grid.x = 30; dim_grid.y = dim_grid.z = 1;
    histogram_kernel<<<dim_grid, dim_block, num_bins*sizeof(unsigned int)>>>
        (input, bins32, num_elements, num_bins);

    // Convert 32-bit bins into 8-bit bins
    dim_block.x = 512;
    dim_grid.x = (num_bins - 1)/dim_block.x + 1;
    convert_kernel<<<dim_grid, dim_block>>>(bins32, bins, num_bins);

    // Free allocated device memory
    cudaFree(bins32);

}


