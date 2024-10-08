#include <iostream>
#include "hip_runtime_api.h"
#include "hip_runtime.h"
using namespace std;

__global__ void add(int* arr1, int* arr2, int* arr3) {
    arr3[threadIdx.x] = arr1[threadIdx.x] + arr2[threadIdx.x];
}

int main() {
    cout << "Hello CMake HIP!\nLets add some arrays!\n";
    int arr1[]={143, 3, 990, 25, 160, 474, 558, 355, 928, 748, 970, 864, 207, 51, 35, 286, 966, 747, 867, 757, 319, 458, 365, 554, 777, 982, 831, 862, 348, 368, 892};
    int arr2[]={845, 390, 539, 208, 136, 677, 70, 24, 178, 841, 652, 149, 748, 541, 860, 431, 564, 497, 502, 175, 237, 253, 480, 510, 799, 246, 33, 835, 922, 217, 967};
    int *cArr1, *cArr2, *cArr3;
    hipMalloc(&cArr1, sizeof(arr1));
    hipMalloc(&cArr2, sizeof(arr2));
    hipMalloc(&cArr3, sizeof(arr1));
    hipMemcpy(cArr1, arr1, sizeof(arr1), hipMemcpyHostToDevice);
    hipMemcpy(cArr2, arr2, sizeof(arr2), hipMemcpyHostToDevice);
    add<<<1, 31>>>(cArr1, cArr2, cArr3);
    int* arr3=new int[sizeof(arr1)/sizeof(arr1[0])];
    hipMemcpy(cArr3, arr3, sizeof(arr2), hipMemcpyDeviceToHost);
    for (int i = 0;i < 31;i++) {
        cout << arr3[i] << ' ';
    }
    cout << endl;
    return 0;
}