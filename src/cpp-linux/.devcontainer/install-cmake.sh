#!/usr/bin/env bash
# CMake binary installer layer.
# Downloads the official binary .sh installer via curl (from base layer),
# runs it, and cleans up. No apt needed.

set -eux

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Script must be run as root." 1>&2
    exit 1
fi

CMAKE_VER="4.2.3"
echo "Downloading CMake ${CMAKE_VER}..."
curl -fsSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.sh" -o "cmake-${CMAKE_VER}-linux-x86_64.sh"

echo "Installing CMake..."
chmod +x cmake-${CMAKE_VER}-linux-x86_64.sh
./cmake-${CMAKE_VER}-linux-x86_64.sh --skip-license --prefix=/usr/local --exclude-subdir
rm -f cmake-${CMAKE_VER}-linux-x86_64.sh

# Remove CMake HTML documentation (~58 MB)
rm -rf /usr/local/doc/cmake*

echo "CMake installed:"
cmake --version
