#!/usr/bin/env bash
# Self-contained LLVM layer.
# Downloads the GitHub release tarball via aria2c (16 parallel connections),
# prunes it to a minimal C++ toolchain, registers update-alternatives,
# then purges temp deps.

set -eux
export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Script must be run as root." 1>&2
    exit 1
fi

# Ensure minimal apt installs
cat > /etc/apt/apt.conf.d/99norecommend << EOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::Acquire::Queue-Mode "access";
Acquire::Queue-Worker::MaxQueue "10";
EOF

apt-get update
# Runtime deps kept in the layer (lldb links against libxml2, libpython, ncurses)
apt-get install -y --no-install-recommends libxml2-16 libpython3.14 libncurses6
# Temp deps purged at end of this layer
apt-get install -y --no-install-recommends aria2

# +-----------------------------+
# | Resolve latest LLVM version |
# +-----------------------------+
LLVM_VER="latest"
if [ "$LLVM_VER" = "latest" ]; then
    LATEST_URL=$(curl -w "%{url_effective}" -L -s -S https://github.com/llvm/llvm-project/releases/latest -o /dev/null)
    LLVM_VER=$(basename "$LATEST_URL" | sed 's/^llvmorg-//')
fi

echo "Downloading LLVM ${LLVM_VER} from official GitHub Release..."
aria2c -x 16 -s 16 -q \
    "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/LLVM-${LLVM_VER}-Linux-X64.tar.xz" \
    -o llvm.tar.xz

echo "Extracting LLVM (multi-threaded decompression)..."
xz -d -T0 llvm.tar.xz
mkdir -p /usr/lib/llvm-${LLVM_VER}
tar -xf llvm.tar -C /usr/lib/llvm-${LLVM_VER} --strip-components=1
rm -f llvm.tar

# +-----------------------------+
# | Prune to minimal toolchain  |
# +-----------------------------+
echo "Reducing LLVM size to a minimal C++ toolchain..."

# 1. /bin - keep only essential compiling/debugging/linting tools
echo " -> Pruning unused LLVM binaries..."
find /usr/lib/llvm-${LLVM_VER}/bin/ -type f \
    | grep -vE '/(clang|clang\+\+|clang-[0-9]+|clang-cpp|lld|ld\.lld|clang-tidy|clangd|clang-format|llvm-ar|llvm-ranlib|llvm-symbolizer|llvm-cov|llvm-profdata|lldb|lldb-[0-9]+|lldb-server|lldb-dap|lldb-argdumper|llvm-strip|llvm-objcopy)$' \
    | xargs rm -f
find /usr/lib/llvm-${LLVM_VER}/bin/ -type f -executable -not -name "llvm-strip" -not -name "llvm-objcopy" -exec /usr/lib/llvm-${LLVM_VER}/bin/llvm-strip {} \; > /dev/null 2>&1 || true

# 2. /lib - remove unused shared libs, static archives, MLIR, Polly
echo " -> Removing unused shared/static libraries..."
# libclang.so (C API, 207 MB) and libclang-cpp.so (C++ API, 105 MB) - not linked by any kept binary
rm -f /usr/lib/llvm-${LLVM_VER}/lib/libclang.so*
rm -f /usr/lib/llvm-${LLVM_VER}/lib/libclang-cpp.so*
# liblldbIntelFeatures (2 MB) - Intel-specific debug features
rm -f /usr/lib/llvm-${LLVM_VER}/lib/liblldbIntelFeatures.so*
# libRemarks.so - optimization remarks API, not needed at runtime
rm -f /usr/lib/llvm-${LLVM_VER}/lib/libRemarks.so*
# MLIR and Polly
find /usr/lib/llvm-${LLVM_VER}/lib -name "libmlir*.so*" -delete > /dev/null 2>&1 || true
rm -f /usr/lib/llvm-${LLVM_VER}/lib/LLVMPolly.so
# All static archives (top-level)
find /usr/lib/llvm-${LLVM_VER}/lib -maxdepth 1 -name "*.a" -delete > /dev/null 2>&1 || true
# Strip remaining .so files
find /usr/lib/llvm-${LLVM_VER}/lib/ -maxdepth 1 -name "*.so*" -type f -exec /usr/lib/llvm-${LLVM_VER}/bin/llvm-strip {} \; > /dev/null 2>&1 || true

# Remove llvm-strip and llvm-objcopy as they are no longer needed for the final image
rm -f /usr/lib/llvm-${LLVM_VER}/bin/llvm-strip /usr/lib/llvm-${LLVM_VER}/bin/llvm-objcopy

# 3. Compiler-RT: remove Fortran runtime and exotic sanitizers, keep core ones
echo " -> Pruning compiler-rt to essential sanitizers..."
CRT_DIR=/usr/lib/llvm-${LLVM_VER}/lib/clang/*/lib/x86_64-unknown-linux-gnu
# Remove Fortran runtime (27 MB)
rm -f ${CRT_DIR}/libflang_rt.*
# Remove exotic sanitizers/tools (keep: asan, tsan, msan, lsan, ubsan, profile, builtins, crt)
rm -f ${CRT_DIR}/libclang_rt.hwasan*.a ${CRT_DIR}/libclang_rt.hwasan*.so
rm -f ${CRT_DIR}/libclang_rt.cfi*.a
rm -f ${CRT_DIR}/libclang_rt.dd*.a
rm -f ${CRT_DIR}/libclang_rt.xray*.a
rm -f ${CRT_DIR}/libclang_rt.scudo*.a
rm -f ${CRT_DIR}/libclang_rt.nsan*.a ${CRT_DIR}/libclang_rt.nsan*.so
rm -f ${CRT_DIR}/libclang_rt.tysan*.a
rm -f ${CRT_DIR}/libclang_rt.rtsan*.a
rm -f ${CRT_DIR}/libclang_rt.ctx_profile*.a
rm -f ${CRT_DIR}/libclang_rt.stats*.a
rm -f ${CRT_DIR}/libclang_rt.dfsan*.a
rm -f ${CRT_DIR}/libclang_rt.memprof*.a ${CRT_DIR}/libclang_rt.memprof*.so

# 4. Remove all remaining headers, cmake configs, build artifacts
echo " -> Removing headers, cmake, and build artifacts..."
rm -rf /usr/lib/llvm-${LLVM_VER}/include \
       /usr/lib/llvm-${LLVM_VER}/lib/cmake \
       /usr/lib/llvm-${LLVM_VER}/lib/objects-RELEASE \
       /usr/lib/llvm-${LLVM_VER}/lib/python3.11 \
       /usr/lib/llvm-${LLVM_VER}/share

# +-----------------------------+
# | Register all tools on PATH  |
# +-----------------------------+
LLVM_PRIO=${LLVM_VER%%.*}
LLVM_BIN=/usr/lib/llvm-${LLVM_VER}/bin

update-alternatives --install /usr/bin/clang            clang            ${LLVM_BIN}/clang            ${LLVM_PRIO}
update-alternatives --install /usr/bin/clang++          clang++          ${LLVM_BIN}/clang++          ${LLVM_PRIO}
update-alternatives --install /usr/bin/clang-tidy       clang-tidy       ${LLVM_BIN}/clang-tidy       ${LLVM_PRIO}
update-alternatives --install /usr/bin/clang-format     clang-format     ${LLVM_BIN}/clang-format     ${LLVM_PRIO}
update-alternatives --install /usr/bin/clangd           clangd           ${LLVM_BIN}/clangd           ${LLVM_PRIO}
update-alternatives --install /usr/bin/lld              lld              ${LLVM_BIN}/lld              ${LLVM_PRIO}
update-alternatives --install /usr/bin/lldb             lldb             ${LLVM_BIN}/lldb             ${LLVM_PRIO}
update-alternatives --install /usr/bin/lldb-dap         lldb-dap         ${LLVM_BIN}/lldb-dap         ${LLVM_PRIO}
update-alternatives --install /usr/bin/lldb-server      lldb-server      ${LLVM_BIN}/lldb-server      ${LLVM_PRIO}
update-alternatives --install /usr/bin/llvm-ar          llvm-ar          ${LLVM_BIN}/llvm-ar          ${LLVM_PRIO}
update-alternatives --install /usr/bin/llvm-ranlib      llvm-ranlib      ${LLVM_BIN}/llvm-ranlib      ${LLVM_PRIO}
update-alternatives --install /usr/bin/llvm-cov         llvm-cov         ${LLVM_BIN}/llvm-cov         ${LLVM_PRIO}
update-alternatives --install /usr/bin/llvm-profdata    llvm-profdata    ${LLVM_BIN}/llvm-profdata    ${LLVM_PRIO}
update-alternatives --install /usr/bin/llvm-symbolizer  llvm-symbolizer  ${LLVM_BIN}/llvm-symbolizer  ${LLVM_PRIO}

# +-----------------------------+
# | Purge temp deps             |
# +-----------------------------+
apt-get purge -y aria2 xz-utils
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

# The LLVM tarball was built on an older distro (libxml2.so.2, libpython3.11).
# Ubuntu Resolute ships libxml2.so.16 and libpython3.13. Create compat symlinks.
LIB_DIR=/usr/lib/x86_64-linux-gnu

LIBXML_ACTUAL=$(find $LIB_DIR -maxdepth 1 -name 'libxml2.so.*' -not -type l | head -1)
if [ -n "$LIBXML_ACTUAL" ] && [ ! -e "$LIB_DIR/libxml2.so.2" ]; then
    ln -s "$LIBXML_ACTUAL" "$LIB_DIR/libxml2.so.2"
fi

LIBPY_ACTUAL=$(find $LIB_DIR -maxdepth 1 -name 'libpython3.14.so.1.0' -not -type l | head -1)
if [ -n "$LIBPY_ACTUAL" ] && [ ! -e "$LIB_DIR/libpython3.11.so.1.0" ]; then
    ln -s "$LIBPY_ACTUAL" "$LIB_DIR/libpython3.11.so.1.0"
fi

ldconfig

echo "LLVM ${LLVM_VER} installed:"
clang --version
lldb --version
