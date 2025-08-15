#!/usr/bin/env bash

set -eux

export DEBIAN_FRONTEND=noninteractive

# log with color
_log() {
    local level=$1
    local msg=${*:2}

    _preset="clear"
    case "$level" in
    "red" | "r" | "error")
        _preset='\033[31m'
        ;;
    "green" | "g" | "success")
        _preset='\033[32m'
        ;;
    "yellow" | "y" | "warning" | "warn")
        _preset='\033[33m'
        ;;
    "blue" | "b" | "info")
        _preset='\033[34m'
        ;;
    "clear" | "c")
        _preset='\033[0m'
        ;;
    esac

    echo -e "$_preset["${level^^}"]:\033[0m $msg" 1>&2
}

if [ "$(id -u)" -ne 0 ]; then
    _log "error" 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

cat > /etc/apt/apt.conf.d/99norecommend << EOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::Get::AllowUnauthenticated "true";
EOF

# # Remove any previous gcc that may be in the base image
# if dpkg -s gcc-11 > /dev/null 2>&1; then
#   apt-get purge -y gcc-* && apt-get autoremove -y
# fi

# # Remove any previous libstdc++ that may be in the base image
# if dpkg -s libstdc++-11-dev > /dev/null 2>&1; then
#   apt-get purge -y libstdc++-* && apt-get autoremove -y
# fi

# # Remove any previous LLVM that may be in the base image
# if dpkg -s llvm-17 > /dev/null 2>&1; then
#   apt-get purge -y llvm-* && apt-get autoremove -y
# fi

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends git git-lfs ninja-build ssh npm
apt-get install -y --no-install-recommends doxygen graphviz ccache cppcheck valgrind
apt-get install -y --no-install-recommends software-properties-common pip curl zip unzip tar pkg-config wget gpg-agent gdb

# Adding test and qualification repository for gcc and clang
# add-apt-repository -y ppa:ubuntu-toolchain-r/test
# add-apt-repository 'deb http://apt.llvm.org/plucky/ llvm-toolchain-plucky-21 main'
# add-apt-repository 'deb-src http://apt.llvm.org/plucky/ llvm-toolchain-plucky-21 main'
# wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

apt-get update

apt-get purge -y cmake && apt-get autoremove -y
apt-get purge -y gcc-* && apt-get autoremove -y
apt-get purge -y libstdc++-* && apt-get autoremove -y
apt-get purge -y llvm-* && apt-get autoremove -y

# +-----------------------------+
# | GCC                         |
# +-----------------------------+
echo "Install GCC"
GCC_VER="15"
apt install -y gcc-${GCC_VER} g++-${GCC_VER} libstdc++-${GCC_VER}-dev
add-apt-repository -y --remove ppa:ubuntu-toolchain-r/test
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} ${GCC_VER}
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} ${GCC_VER}

# +-----------------------------+
# | LLVM                        |
# +-----------------------------+
echo "Install LLVM"
LLVM_VER="20"

# Automatic installation script
# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh
# ./llvm.sh ${LLVM_VER}
# rm ./llvm.sh

# Install stable branch
apt-get install -y --no-install-recommends clang-${LLVM_VER} lldb-${LLVM_VER} lld-${LLVM_VER} \
        clangd-${LLVM_VER} clang-tidy-${LLVM_VER} clang-format-${LLVM_VER} libc++-${LLVM_VER}-dev \
        libc++abi-${LLVM_VER}-dev libclang-rt-${LLVM_VER}-dev llvm-$LLVM_VER-dev

if [ -f /usr/lib/llvm-20 ]; then
    rm -rf /usr/lib/llvm-20
fi

# unversionize the binaries
for bin in /usr/lib/llvm-${LLVM_VER}/bin/*; do
  bin=$(basename ${bin})
  if [ -f /usr/bin/${bin}-${LLVM_VER} ]; then
    ln -sf /usr/bin/${bin}-${LLVM_VER} /usr/bin/${bin}
  fi
done

# Set the default clang-tidy, so CMake can find it
update-alternatives --install /usr/bin/clang-tidy clang-tidy $(which clang-tidy-${LLVM_VER}) ${LLVM_VER}
update-alternatives --install /usr/bin/clang-format clang-format $(which clang-format-${LLVM_VER}) ${LLVM_VER}

# Set clang-${LLVM_VER} as default clang
update-alternatives --install /usr/bin/clang clang $(which clang-${LLVM_VER}) ${LLVM_VER}
update-alternatives --install /usr/bin/clang++ clang++ $(which clang++-${LLVM_VER}) ${LLVM_VER}

# +-----------------------------+
# | CMake                       |
# +-----------------------------+
echo "Install cmake"
pip install cmake --no-cache-dir --break-system-packages

#Use binary from Kitware to gety 3.29 because 3.28.3 causes issue with clang-tidy on noble.
# if dpkg -s cmake > /dev/null 2>&1; then
#    apt-get purge -y cmake && apt-get autoremove -y
# fi
# wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh
# chmod +x cmake-3.28.3-linux-x86_64.sh
# ./cmake-3.28.3-linux-x86_64.sh --skip-license --prefix=/usr/local --exclude-subdir

# update-alternatives --install /usr/bin/cmake cmake /usr/local/cmake-3.28.3-linux-x86_64/bin/cmake 3290
# update-alternatives --install /usr/bin/ccmake ccmake /usr/local/cmake-3.28.3-linux-x86_64/bin/ccmake 3290
# update-alternatives --install /usr/bin/cmake-gui cmake-gui /usr/local/cmake-3.28.3-linux-x86_64/bin/cmake-gui 3290
# update-alternatives --install /usr/bin/cpack cpack /usr/local/cmake-3.28.3-linux-x86_64/bin/cpack 3290
# update-alternatives --install /usr/bin/ctest ctest /usr/local/cmake-3.28.3-linux-x86_64/bin/ctest 3290

# wget https://apt.kitware.com/kitware-archive.sh
# chmod +x kitware-archive.sh
# ./kitware-archive.sh
# apt install -y cmake


# Install Powershell
# source /etc/os-release
# wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
# dpkg -i packages-microsoft-prod.deb
# rm packages-microsoft-prod.deb
# apt-get update
# apt-get install -y powershell


# Cleaning
echo "Cleanup"
pip cache remove cmake
pip cache purge
apt-get purge -y software-properties-common pip libmpfr-dev libgmp3-dev libmpc-dev
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*
rm -f /etc/apt/apt.conf.d/99norecommend

git --version
cmake --version
echo "Ninja"
ninja --version
gcc --version
clang --version
# pwsh --version