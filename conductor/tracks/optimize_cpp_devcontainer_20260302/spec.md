# Track Specification: Optimize C++ Devcontainer Size and Functionality

## Overview
The goal of this track is to analyze and significantly reduce the size of the C++ devcontainer image located in `src/cpp-linux/.devcontainer/`, while maintaining critical functionalities such as compiling C/C++ with the latest Clang and GCC, debugging with GDB and LLDB, standard Clang tools, Sanitizers, and LTO.

## Objectives
- Analyze the current `Dockerfile` and installation scripts to identify size bottlenecks.
- Implement multi-stage builds or layer caching optimizations.
- Replace heavy base images or dependencies with lighter alternatives where applicable.
- Ensure all specified C++ tools (compilers, debuggers, sanitizers, LTO) remain functional.
- Validate that the devcontainer can successfully build a sample C++ project with LTO and sanitizers enabled.

## Non-Goals
- Adding new features to the devcontainer that are not related to C++ compilation, debugging, or optimization.
- Moving to an entirely different architecture (e.g., Alpine) if it breaks glibc-dependent C++ tools, unless compatibility is fully resolved.