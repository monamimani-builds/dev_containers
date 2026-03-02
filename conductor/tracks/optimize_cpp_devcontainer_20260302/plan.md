# Implementation Plan: Optimize C++ Devcontainer Size and Functionality

## Phase 1: Analysis and Profiling
- [x] Task: Write Tests [9909880]
    - [x] Create a sample C++ project in the repository for validation (e.g., `tests/sample-cpp-project`) that exercises CMake, GCC, Clang, LTO, and sanitizers.
- [x] Task: Implement Feature - Analyze current devcontainer size [2f62017]
    - [x] Build the current `cpp-linux` devcontainer image and inspect its layers.
    - [x] Document the largest layers and dependencies contributing to the image size.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Analysis and Profiling' (Protocol in workflow.md)

## Phase 2: Base Image and Layer Optimization
- [ ] Task: Write Tests
    - [ ] Update the CI/CD pipeline or local test scripts to assert the image size does not exceed a new target threshold.
- [ ] Task: Implement Feature - Optimize Dockerfile and base image
    - [ ] Refactor `Dockerfile` to combine `RUN` statements, minimize intermediate layers, and aggressively clean up `apt-get` caches (`rm -rf /var/lib/apt/lists/*`).
    - [ ] Evaluate and optionally switch to a slimmer base image (e.g., `ubuntu:22.04` minimal or `debian:bullseye-slim`).
    - [ ] Refactor installation scripts (`install-base.sh`, `install-cmake.sh`, `install-gcc.sh`, `install-llvm.sh`, `install-vcpkg.sh`) to remove unnecessary documentation, man pages, and temporary files during installation.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Base Image and Layer Optimization' (Protocol in workflow.md)

## Phase 3: Toolchain Verification and Finalization
- [ ] Task: Write Tests
    - [ ] Add explicit build steps in the test project for both GCC and Clang.
    - [ ] Add explicit build steps demonstrating GDB/LLDB debugging symbols are present.
- [ ] Task: Implement Feature - Verify functionality
    - [ ] Build the optimized devcontainer image.
    - [ ] Run the sample C++ project compilation using the new devcontainer, verifying LTO and sanitizers work without errors.
    - [ ] Verify GDB and LLDB can successfully attach and debug the sample project.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Toolchain Verification and Finalization' (Protocol in workflow.md)