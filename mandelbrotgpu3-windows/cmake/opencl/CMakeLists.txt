# HIP version of mandelbrotgpu3-windows

cmake_minimum_required (VERSION 3.30.4)
project ("mandelbrotgpu3-windows-opencl" VERSION 1.0 DESCRIPTION "Open source mandelbrotgpu3 for windows for compatible." LANGUAGES CXX)
include("C:\\Users\\teren\\Documents\\vcpkg-master\\vcpkg-master\\scripts\\buildsystems\\vcpkg.cmake")
find_package(OpenCL REQUIRED)
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
add_definitions(-DCL_TARGET_OPENCL_VERSION=300)
add_executable (main main-opengl.cxx)
target_link_libraries(main ${OpenCV_LIBS})
target_link_libraries(main OpenCL::OpenCL)
set (CMAKE_CXX_STANDARD 20)
set (CMAKE_CXX_STANDARD_REQUIRED True)