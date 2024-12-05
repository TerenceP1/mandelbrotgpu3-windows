#include <iostream>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cuda.h>
#include <cuda_runtime_api.h>
#include <cuda_fp16.h>
#include <cuda_profiler_api.h>
#include <cuda_device_runtime_api.h>
#include <cuda_texture_types.h>
#include <cuda_surface_types.h>
#include <vector_types.h>
using namespace std;

__global__ void add(int* arr1, int* arr2, int* arr3) {
    arr3[threadIdx.x] = arr1[threadIdx.x] + arr2[threadIdx.x];
}

int main() {
    cout << "Hello CMake CUDA!\nLets add some arrays!\n";
    int arr1[]={143, 3, 990, 25, 160, 474, 558, 355, 928, 748, 970, 864, 207, 51, 35, 286, 966, 747, 867, 757, 319, 458, 365, 554, 777, 982, 831, 862, 348, 368, 892};
    int arr2[]={845, 390, 539, 208, 136, 677, 70, 24, 178, 841, 652, 149, 748, 541, 860, 431, 564, 497, 502, 175, 237, 253, 480, 510, 799, 246, 33, 835, 922, 217, 967};
    int *cArr1, *cArr2, *cArr3;
    cudaMalloc(&cArr1, sizeof(arr1));
    cudaMalloc(&cArr2, sizeof(arr2));
    cudaMalloc(&cArr3, sizeof(arr1));
    cudaMemcpy(cArr1, arr1, sizeof(arr1), cudaMemcpyHostToDevice);
    cudaMemcpy(cArr2, arr2, sizeof(arr2), cudaMemcpyHostToDevice);
    add<<<1, 31>>>(cArr1, cArr2, cArr3);
    int* arr3;
    cudaMemcpy(cArr3, arr3, sizeof(arr2), cudaMemcpyDeviceToHost);
    for (int i = 0;i < 31;i++) {
        cout << arr3[i] << ' ';
    }
    cout << endl;
    return 0;
}