cmake_minimum_required(VERSION 3.10)
project(SampleCppProject)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(sample_project main.cpp)

# Enable LTO if available
include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported OUTPUT error)
if(ipo_supported)
    set_property(TARGET sample_project PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
    message(STATUS "LTO enabled")
else()
    message(STATUS "LTO not supported: ${error}")
endif()
