#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
apt-get update 
apt-get upgrade -y
apt-get install -y --no-install-recommends git git-lfs sudo wget
apt-get install -y --no-install-recommends software-properties-common
apt-get install -y --no-install-recommends make ninja-build doxygen graphviz ccache cppcheck

pushd /tmp/
echo "Install cmake"
wget https://apt.kitware.com/kitware-archive.sh
chmod +x kitware-archive.sh
./kitware-archive.sh
apt install -y cmake

echo "Install LLVM"
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh

LLVM_VER="18"
./llvm.sh ${LLVM_VER} clang-${LLVM_VER} lldb-${LLVM_VER} lld-${LLVM_VER} clangd-${LLVM_VER} \
          llvm-${LLVM_VER}-dev libclang-${LLVM_VER}-dev clang-tidy-${LLVM_VER} clang-format-${LLVM_VER} \
          libc++-${LLVM_VER}-dev libc++abi-${LLVM_VER}-dev 
popd

# # vcpkg: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
# pushd $VCPKG_ROOT
# git config --system --add safe.directory "$VCPKG_ROOT" 
# git fetch --unshallow
# git pull --ff-only
# bootstrap-vcpkg.sh
# popd


# Set the default clang-tidy, so CMake can find it
update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VER}) 1

# Set clang-${LLVM_VER} as default clang
update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VER}) 100
update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${LLVM_VER}) 100

# Cleaning
apt-get purge software-properties-common
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*

git --version
ninja --version
gcc --version
clang --version