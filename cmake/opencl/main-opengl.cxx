#include <iostream>
#include <CL/cl.h>
#include <CL/cl_gl.h>
#include <CL/cl_ext.h>
#include <CL/cl_platform.h>
#include <vector>
#include <fstream>
#include <sstream>
#include <Windows.h>
#define uint unsigned int

#pragma comment(lib, "OpenGL32.lib")
using namespace std;

typedef struct {
  cl_mem data;
  // uint *tmp; ineffecient waste of space// temporary storage with double the
  // size of data
  uint size;  // size of data array. data  is in big edian and has 32 bits of
              // integer and dprec of decimal
  uint dprec; // just for convenience: may or may not be used. dprec=size-1
} decimal;

typedef struct {
  cl_mem x, y, nx, ny, ox, oy; // ox and oy are original x and y. sqTmp is for storing y^2(useless)
  cl_mem tmp;
  cl_mem re; // string with re in decimal
  cl_mem im; // string with im in decimal
  cl_mem tDig; // stores a digit or 10 during string to decimal conversion and bound check
  cl_mem tenth; // stores one tenth or a power of it
  cl_mem xSq, ySq; // for checking whether number exceeded bounds
  cl_mem rgb; // stores rgb values for pixels row by row with r then g then b
  int maxItr;
} kernelIn;

string slurp(string nm)
{
    ifstream in(nm);
    stringstream a;
    a << in.rdbuf();
    return a.str();
}

int main()
{
  
    // Get a context

    cl_platform_id platform;
    cl_device_id device;
    cl_context context;
    clGetPlatformIDs(1, &platform, nullptr);
    clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, nullptr);
    char *name; // CL_DEVICE_NAME
    size_t len;
    char *vendor; // CL_DEVICE_VENDOR

    clGetDeviceInfo(
        device,
        CL_DEVICE_NAME,
        NULL,
        NULL,
        &len);
    cout << "name length: " << len << endl;
    name = new char[len];
    clGetDeviceInfo(
        device,
        CL_DEVICE_NAME,
        len,
        name,
        NULL);
    string nstr(name, len);
    cout << "name: " << nstr << endl;
    clGetDeviceInfo(
        device,
        CL_DEVICE_NAME,
        NULL,
        NULL,
        &len);
    cout << "vendor length: " << len << endl;
    vendor = new char[len];
    clGetDeviceInfo(
        device,
        CL_DEVICE_NAME,
        len,
        vendor,
        NULL);
    string nstr2(vendor, len);
    cout << "vendor: " << nstr2 << endl;
    char *version;
    clGetDeviceInfo(
        device,
        CL_DEVICE_VERSION,
        NULL,
        NULL,
        &len);
    cout << "version length: " << len << endl;
    version = new char[len];
    clGetDeviceInfo(
        device,
        CL_DEVICE_VERSION,
        len,
        version,
        NULL);
    string nstr3(version, len);
    cout << "version: " << nstr3 << endl;
    string code = slurp("kernel.cl");
    context = clCreateContext(
        NULL,
        1,
        &device,
        NULL,
        NULL,
        NULL);
    // Make program

    cl_command_queue queue;
    cl_program program;
    queue = clCreateCommandQueueWithProperties(
        context,
        device,
        NULL,
        NULL);
    const char *prg = code.c_str();
    const size_t len2 = code.length();
    program = clCreateProgramWithSource(
        context,
        1,
        &prg,
        &len2,
        NULL);
    clBuildProgram(
        program,
        1,
        &device,
        NULL,
        NULL,
        NULL);
    size_t logL;
    clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, 0, NULL, &logL);
    char *blog = new char[logL];
    clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, logL, blog, NULL);
    cout << "Log:\n"
         << blog << endl;
    cout << "Program created!!!!!!!\n";
    // make buffers
    // just testing opencl from here
    cl_mem a = clCreateBuffer(
        context,
        CL_MEM_READ_WRITE,
        sizeof(uint),
        NULL,
        NULL);
    cl_mem b = clCreateBuffer(
        context,
        CL_MEM_READ_WRITE,
        sizeof(uint),
        NULL,
        NULL);
    cl_mem c = clCreateBuffer(
        context,
        CL_MEM_READ_WRITE,
        sizeof(uint),
        NULL,
        NULL);
    int prec=4;
    kernelIn inp;
    inp.x=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.y=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.nx=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.ny=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.ox=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.oy=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.tmp=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(int)*(5*prec+5),NULL,NULL);
    inp.tDig=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.tenth=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.xSq=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.ySq=clCreateBuffer(context,CL_MEM_READ_WRITE,sizeof(decimal),NULL,NULL);
    inp.maxItr=1000;
    decimal tDec;
    tDec.size=prec+1;
    tDec.dprec=prec;
    uint tmp = 3;
    clEnqueueWriteBuffer(
        queue,
        a,
        CL_TRUE,
        0,
        sizeof(uint),
        &tmp,
        NULL,
        NULL,
        NULL);
    clEnqueueWriteBuffer(
        queue,
        b,
        CL_TRUE,
        0,
        sizeof(uint),
        &tmp,
        NULL,
        NULL,
        NULL);
    // Run kernel
    cl_kernel kernel = clCreateKernel(
        program,
        "test",
        NULL);
    clSetKernelArg(
        kernel,
        0,
        sizeof(cl_mem),
        &a);
    clSetKernelArg(
        kernel,
        1,
        sizeof(cl_mem),
        &b);
    clSetKernelArg(
        kernel,
        2,
        sizeof(cl_mem),
        &c);
    size_t zzz = 1;
    cout << "kernel!!!" << clEnqueueNDRangeKernel(queue, kernel, 1, NULL, &zzz, NULL, NULL, NULL, NULL)
         << endl;
    // Sleep(15000);
    clFlush(queue);
    cout << clFinish(queue) << endl;
    // Read the result
    uint res = 19;
    clEnqueueReadBuffer(
        queue,
        c,
        CL_TRUE,
        0,
        sizeof(uint),
        &res,
        NULL,
        NULL,
        NULL);
    cout << "Result of " << res << endl;
    clReleaseKernel(kernel);
    clReleaseMemObject(a);
    clReleaseMemObject(b);
    clReleaseMemObject(c);
    clReleaseMemObject(inp.x);
    clReleaseMemObject(inp.y);
    clReleaseMemObject(inp.nx);
    clReleaseMemObject(inp.ny);
    clReleaseMemObject(inp.ox);
    clReleaseMemObject(inp.oy);
    clReleaseMemObject(inp.tmp);
    clReleaseMemObject(inp.tDig);
    clReleaseMemObject(inp.tenth);
    clReleaseMemObject(inp.xSq);
    clReleaseMemObject(inp.ySq);
    clReleaseProgram(program);
    clReleaseCommandQueue(queue);
    clReleaseContext(context);
    cout<<"Please note my code is incomplete and in development."<<endl;
    return 0;
}
