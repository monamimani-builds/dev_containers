# Analysis of C++ Devcontainer Size

## Current State
The devcontainer image for `cpp-linux` is composed of several layers, each installing a significant set of tools. Based on the `Dockerfile` and installation scripts, the following bottlenecks have been identified.

### 1. LLVM Toolchain (`install-llvm.sh`)
- **Status**: Currently downloads the full official GitHub release tarball.
- **Size Bottleneck**: Even with the aggressive pruning of binaries and shared libraries, the resulting installation is likely the largest component (>500MB).
- **Potential Optimization**:
    - Use a more targeted download if possible, or further prune non-essential components.
    - Check if `libclang.so` is truly unnecessary (currently deleted, saving 207MB).
    - Ensure headers needed for compilation are preserved while removing non-essential ones.

### 2. vcpkg (`install-vcpkg.sh`)
- **Status**: Clones the entire GitHub repository.
- **Size Bottleneck**: The `.git` directory and the repository content take up significant space (~200MB+).
- **Potential Optimization**:
    - Use a shallow clone (`--depth=1`).
    - Remove the `.git` directory after bootstrapping if ongoing updates are not required within the container.
    - Prune unnecessary architectures/triplets.

### 3. Base Image and Packages (`install-base.sh`)
- **Status**: Uses `ubuntu:resolute`.
- **Size Bottleneck**: Includes heavy tools like `npm`, `doxygen`, and `graphviz`.
- **Potential Optimization**:
    - Switch to `ubuntu:22.04-slim` or a similar minimal base.
    - Evaluate if `npm` is required for C++ development.
    - Move `doxygen` and `graphviz` to an optional layer or multi-stage build if not used by all developers.

### 4. Dockerfile Layering
- **Status**: Each installation script is its own `RUN` layer.
- **Size Bottleneck**: Layer overhead and potential duplicate metadata.
- **Potential Optimization**:
    - Combine related `RUN` steps to reduce layer count.
    - Ensure `apt` caches are cleaned in the same layer they are created.

## Estimated Size Breakdown
| Component | Estimated Size |
|-----------|----------------|
| LLVM (Pruned) | 500 MB |
| GCC | 150 MB |
| vcpkg (Repo + Tool) | 200 MB |
| Base Image + Tools | 250 MB |
| **Total** | **~1.1 GB** |
