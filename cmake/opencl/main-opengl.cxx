#include <iostream>
#include <CL/cl.h>
#include <CL/cl_gl.h>
#include <CL/cl_ext.h>
#include <CL/cl_platform.h>
#include <vector>
#pragma comment(lib, "OpenGL32.lib")
using namespace std;

const char *programSource = R"(
__kernel void vecAdd(__global const float* A, __global const float* B, __global float* C) {
    int idx = get_global_id(0);
    C[idx] = A[idx] + B[idx];
}
)";

int main()
{
    // Initialize data
    const int elements = 1024;
    std::vector<float> A(elements, 1.0f);
    std::vector<float> B(elements, 2.0f);
    std::vector<float> C(elements);

    // Get platform and device information
    cl_platform_id platform;
    cl_device_id device;
    clGetPlatformIDs(1, &platform, nullptr);
    clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, nullptr);

    // Create an OpenCL context
    cl_context context = clCreateContext(nullptr, 1, &device, nullptr, nullptr, nullptr);

    // Create a command queue
    cl_command_queue queue = clCreateCommandQueue(context, device, 0, nullptr);

    // Create memory buffers on the device
    cl_mem bufferA = clCreateBuffer(context, CL_MEM_READ_ONLY, elements * sizeof(float), nullptr, nullptr);
    cl_mem bufferB = clCreateBuffer(context, CL_MEM_READ_ONLY, elements * sizeof(float), nullptr, nullptr);
    cl_mem bufferC = clCreateBuffer(context, CL_MEM_WRITE_ONLY, elements * sizeof(float), nullptr, nullptr);

    // Copy the lists A and B to their respective memory buffers
    clEnqueueWriteBuffer(queue, bufferA, CL_TRUE, 0, elements * sizeof(float), A.data(), 0, nullptr, nullptr);
    clEnqueueWriteBuffer(queue, bufferB, CL_TRUE, 0, elements * sizeof(float), B.data(), 0, nullptr, nullptr);

    // Create a program from the kernel source
    cl_program program = clCreateProgramWithSource(context, 1, &programSource, nullptr, nullptr);
    clBuildProgram(program, 1, &device, nullptr, nullptr, nullptr);

    // Create the OpenCL kernel
    cl_kernel kernel = clCreateKernel(program, "vecAdd", nullptr);

    // Set the arguments of the kernel
    clSetKernelArg(kernel, 0, sizeof(cl_mem), &bufferA);
    clSetKernelArg(kernel, 1, sizeof(cl_mem), &bufferB);
    clSetKernelArg(kernel, 2, sizeof(cl_mem), &bufferC);

    // Execute the OpenCL kernel
    size_t globalSize = elements;
    clEnqueueNDRangeKernel(queue, kernel, 1, nullptr, &globalSize, nullptr, 0, nullptr, nullptr);

    // Read the memory buffer C on the device to the local variable C
    clEnqueueReadBuffer(queue, bufferC, CL_TRUE, 0, elements * sizeof(float), C.data(), 0, nullptr, nullptr);

    // Display the result
    for (int i = 0; i < elements; i++)
    {
        cout << C[i] << " ";
    }
    cout << std::endl;

    // Clean up
    clReleaseKernel(kernel);
    clReleaseProgram(program);
    clReleaseMemObject(bufferA);
    clReleaseMemObject(bufferB);
    clReleaseMemObject(bufferC);
    clReleaseCommandQueue(queue);
    clReleaseContext(context);

    return 0;
}