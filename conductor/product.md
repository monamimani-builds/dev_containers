# Product Guide

## Vision
To maintain a high-performance, functionally complete, and optimized C++ development container. The focus is on providing a seamless development experience for modern C++ while minimizing image size without compromising critical features.

## Target Users
- C++ Developers working within a containerized environment (Devcontainers).

## Core Goals
- **Size Optimization**: Analyze and significantly reduce the footprint of the C++ devcontainer.
- **Compiler Support**: Fully support compiling C/C++ with the latest versions of Clang and GCC.
- **Debugging & Tooling**: Provide fully functional debugging capabilities using GDB and LLDB, alongside standard Clang tools.
- **Advanced Features**: Support advanced compilation techniques, including Link Time Optimization (LTO) and Sanitizers.
- **Maintenance**: Ensure that future updates maintain a balance between functionality and image size.

## Key Features
- Pre-configured `devcontainer.json` for C++ development.
- Optimized Dockerfile and installation scripts for base dependencies, CMake, GCC, LLVM, and vcpkg.
- Integrated support for sanitizers and LTO out-of-the-box.