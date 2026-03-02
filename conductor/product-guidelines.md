# Product Guidelines

## General Principles
- **Efficiency:** Devcontainers must be lean, ensuring minimal download times, fast startup, and efficient resource usage on host systems.
- **Reproducibility:** The development environment should be strictly reproducible. Avoid dependencies on the host machine wherever possible.
- **Usability:** Provide out-of-the-box support for the primary IDEs (e.g., VS Code) and necessary tools (compilers, debuggers).

## Design & Architecture
- **Layer Optimization:** Construct Dockerfiles with optimal layer caching in mind. Combine commands (e.g., `apt-get update` and `apt-get install`) where it reduces final image size.
- **Base Images:** Prefer minimal base images (like Alpine, Debian slim, or Ubuntu slim) unless specific tooling necessitates a heavier base.
- **Multi-stage Builds:** When applicable, compile large dependencies or tools in a separate stage and copy only the necessary artifacts into the final devcontainer image.
- **Clean Up:** Aggressively clean up temporary files, package manager caches, and unnecessary build artifacts within the same `RUN` step to prevent image bloat.

## Maintainability
- **Modularity:** Use separate scripts for installing different components (e.g., GCC, LLVM, CMake) to keep the `Dockerfile` clean and maintainable.
- **Documentation:** Inline comments must clarify *why* specific non-standard configuration choices or packages are installed.
- **Version Pinning:** Explicitly pin critical toolchain versions (like compilers and build systems) to prevent unexpected breakages on rebuild.