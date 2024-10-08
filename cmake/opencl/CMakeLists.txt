# HIP version of mandelbrotgpu3-windows

cmake_minimum_required (VERSION 3.30.4)
project ("mandelbrotgpu3-windows-opencl" VERSION 1.0 DESCRIPTION "Open source mandelbrotgpu3 for windows for compatible." LANGUAGES CXX)
find_package(OpenCL REQUIRED)
#add_library(opencl_lib OpenCL::OpenCL)
#target_link_libraries(opencl_lib OpenCL::OpenCL)
add_executable (mandelbrotgpu3-windows-opencl main-opengl.cxx)
set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED True)