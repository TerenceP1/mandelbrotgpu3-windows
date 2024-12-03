# CUDA version of mandelbrotgpu3-windows

set (CMAKE_CUDA_ARCHITECTURES 75)
set (CMAKE_CUDA_FLAGS "--cudart=static")
cmake_minimum_required (VERSION 3.30.4)
project ("mandelbrotgpu3-windows-cuda" VERSION 1.0 DESCRIPTION "Open source mandelbrotgpu3 for windows for CUDA capable GPUs." LANGUAGES CXX CUDA)
add_executable (mandelbrotgpu3-windows-cuda main-cuda.cu)
set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED True)