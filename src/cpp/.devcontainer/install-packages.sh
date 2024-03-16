#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

cat > /etc/apt/apt.conf.d/99norecommend << EOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
EOF

apt-get update 
apt-get upgrade -y
apt-get install -y --no-install-recommends git git-lfs sudo wget
apt-get install -y --no-install-recommends software-properties-common build-essential pkg-config
apt-get install -y --no-install-recommends ninja-build doxygen graphviz ccache cppcheck valgrind tar curl zip unzip

pushd /tmp/
echo "Install cmake"
# wget https://apt.kitware.com/kitware-archive.sh
# chmod +x kitware-archive.sh
# ./kitware-archive.sh
apt install -y cmake

echo "Install LLVM"
# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh

LLVM_VER="18"
# ./llvm.sh ${LLVM_VER}

apt-get install -y --no-install-recommends clang-${LLVM_VER} lldb-${LLVM_VER} lld-${LLVM_VER} clangd-${LLVM_VER} \
                      clang-tidy-${LLVM_VER} clang-format-${LLVM_VER} libc++-${LLVM_VER}-dev libc++abi-${LLVM_VER}-dev
popd

# Set the default clang-tidy, so CMake can find it
update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VER}) 1

# Set clang-${LLVM_VER} as default clang
update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VER}) 100
update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${LLVM_VER}) 100

# vcpkg: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
mkdir -p "${VCPKG_ROOT}"
mkdir -p "${VCPKG_DOWNLOADS}"
pushd $VCPKG_ROOT
SHALLOW_CLONE_DATE=$(date -d "-1 years" +%s)
git clone \
    --depth=1 \
    -c core.eol=lf \
    -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    https://github.com/microsoft/vcpkg .

    #--shallow-since=${SHALLOW_CLONE_DATE} \
    # --single-branch \
    # --branch=master \
    # --no-tags \

git config --system --add safe.directory "$VCPKG_ROOT" 
git fetch --unshallow
git pull --ff-only
bootstrap-vcpkg.sh
popd

# Add vcpkg to PATH
updaterc "$(cat << EOF
export VCPKG_ROOT="${VCPKG_ROOT}"
if [[ "\${PATH}" != *"\${VCPKG_ROOT}"* ]]; then export PATH="\${PATH}:\${VCPKG_ROOT}"; fi
EOF
)"

# Enable tab completion for bash and zsh
VCPKG_FORCE_SYSTEM_BINARIES=1 su "${USERNAME}" -c "${VCPKG_ROOT}/vcpkg integrate bash"
VCPKG_FORCE_SYSTEM_BINARIES=1 su "${USERNAME}" -c "${VCPKG_ROOT}/vcpkg integrate zsh"

# Cleaning
apt-get purge software-properties-common
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -f /etc/apt/apt.conf.d/99norecommend

git --version
cmake --version
echo "Ninja"
ninja --version
gcc --version
clang --version