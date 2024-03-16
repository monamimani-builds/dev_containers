#!/usr/bin/env bash

apt-get update 
apt-get upgrade -y
sudo apt-get install -y --no-install-recommends software-properties-common git git-lfs

pushd /tmp/
echo "Install cmake"
wget https://apt.kitware.com/kitware-archive.sh
chmod +x kitware-archive.sh
sudo ./kitware-archive.sh
sudo apt install -y cmake

echo "Install LLVM"
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh all

gcc --version
clang --version
popd

# # vcpkg: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
# pushd $VCPKG_ROOT
# git config --system --add safe.directory "$VCPKG_ROOT" 
# git fetch --unshallow
# git pull --ff-only
# bootstrap-vcpkg.sh
# popd



# Cleaning
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*