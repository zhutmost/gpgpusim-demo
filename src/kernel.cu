#include <cuda_runtime.h>
#include "../include/kernel.cuh"

__global__ void kernel_add(int * a, int * b, int *c) {
    *c = *a + *b;
}

void my_add(int * a, int * b, int * c) {
    int * cu_a;
    int * cu_b;
    int * cu_c;
    cudaMalloc((void **)&cu_a, sizeof(int));
    cudaMalloc((void **)&cu_b, sizeof(int));
    cudaMalloc((void **)&cu_c, sizeof(int));

    cudaMemcpy(cu_a, a, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(cu_b, b, sizeof(int), cudaMemcpyHostToDevice);
    kernel_add<<<1, 1>>>(cu_a, cu_b, cu_c);
    cudaMemcpy(c, cu_c, sizeof(int), cudaMemcpyDeviceToHost);

    return;
}
