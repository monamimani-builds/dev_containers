# Configuration
$ImageName = "cpp-linux-optimized:latest"

Write-Host "--- Starting Toolchain Verification for $ImageName ---"

# 1. Version Checks
Write-Host "`n[1/3] Verifying Tool Versions..."
docker run --rm $ImageName bash -c "gcc --version | head -n 1; g++ --version | head -n 1; clang --version | head -n 1; lldb --version | head -n 1; clang-scan-deps --version | head -n 1; cmake --version | head -n 1; ninja --version; node --version; doxygen --version"
if ($LASTEXITCODE -ne 0) { Write-Error "Version check failed!"; exit 1 }

# 2. Build with GCC + ASan/UBSan + LTO (using standard GNU ld)
Write-Host "`n[2/3] Building with GCC (LTO + Sanitizers)..."
$gccCmd = "rm -rf build_gcc && mkdir -p build_gcc && cd build_gcc && cmake -G Ninja -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_CXX_FLAGS='-fsanitize=address,undefined' .. && ninja && ./sample_project"
docker run --rm -v "${PWD}:/workspaces/dev_containers" -w /workspaces/dev_containers/tests/sample-cpp-project $ImageName bash -c "$gccCmd"
if ($LASTEXITCODE -ne 0) { Write-Error "GCC Build failed!"; exit 1 }

# 3. Build with Clang + ASan/UBSan + LTO (using LLVM lld)
Write-Host "`n[3/3] Building with Clang (LTO + Sanitizers)..."
$clangCmd = "rm -rf build_clang && mkdir -p build_clang && cd build_clang && LDFLAGS='-fuse-ld=lld' cmake -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_AR=llvm-ar -DCMAKE_RANLIB=llvm-ranlib -DCMAKE_C_FLAGS='-fuse-ld=lld' -DCMAKE_CXX_FLAGS='-fsanitize=address,undefined -fuse-ld=lld' .. && ninja && ./sample_project"
docker run --rm -v "${PWD}:/workspaces/dev_containers" -w /workspaces/dev_containers/tests/sample-cpp-project $ImageName bash -c "$clangCmd"
if ($LASTEXITCODE -ne 0) { Write-Error "Clang LTO Build failed!"; exit 1 }

Write-Host "`nSUCCESS: Toolchain is fully functional!"
