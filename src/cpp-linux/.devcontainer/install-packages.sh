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
apt-get install -y --no-install-recommends software-properties-common pip curl zip unzip tar xz-utils pkg-config wget gpg-agent gdb

# Adding test and qualification repository for clang
# add-apt-repository 'deb http://apt.llvm.org/plucky/ llvm-toolchain-plucky-21 main'
# add-apt-repository 'deb-src http://apt.llvm.org/plucky/ llvm-toolchain-plucky-21 main'
# wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

apt-get update

apt-get purge -y cmake && apt-get autoremove -y
apt-get purge -y gcc-* && apt-get autoremove -y
apt-get purge -y libstdc++-* && apt-get autoremove -y
apt-get purge -y llvm-* && apt-get autoremove -y

# +-----------------------------+
# | LLVM                        |
# +-----------------------------+
echo "Install LLVM"

LLVM_VER="latest"
if [ "$LLVM_VER" = "latest" ]; then
    # Fetch the absolute latest release tag from GitHub dynamically using curl
    LATEST_URL=$(curl -w "%{url_effective}" -L -s -S https://github.com/llvm/llvm-project/releases/latest -o /dev/null)
    LLVM_VER=$(basename $LATEST_URL | sed 's/^llvmorg-//')
fi

echo "Downloading LLVM ${LLVM_VER} from official GitHub Release..."
wget -q "https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VER}/LLVM-${LLVM_VER}-Linux-X64.tar.xz" -O llvm.tar.xz

echo "Extracting LLVM..."
mkdir -p /usr/lib/llvm-${LLVM_VER}
tar -xf llvm.tar.xz -C /usr/lib/llvm-${LLVM_VER} --strip-components=1

echo "Cleaning up archive..."
rm -f llvm.tar.xz





# unversionize the binaries
for bin in /usr/lib/llvm-${LLVM_VER}/bin/*; do
  bin=$(basename ${bin})
  if [ -f /usr/bin/${bin}-${LLVM_VER} ]; then
    ln -sf /usr/bin/${bin}-${LLVM_VER} /usr/bin/${bin}
  fi
done

# Set the default clang-tidy, so CMake can find it
update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/lib/llvm-${LLVM_VER}/bin/clang-tidy ${LLVM_VER%%.*}
update-alternatives --install /usr/bin/clang-format clang-format /usr/lib/llvm-${LLVM_VER}/bin/clang-format ${LLVM_VER%%.*}

# Set clang-${LLVM_VER} as default clang
update-alternatives --install /usr/bin/clang clang /usr/lib/llvm-${LLVM_VER}/bin/clang ${LLVM_VER%%.*}
update-alternatives --install /usr/bin/clang++ clang++ /usr/lib/llvm-${LLVM_VER}/bin/clang++ ${LLVM_VER%%.*}

# +-----------------------------+
# | GCC                         |
# +-----------------------------+
echo "Install GCC"

GCC_VER="latest"

source /etc/os-release
UBUNTU_CODENAME=$VERSION_CODENAME

# Add the proposed repository for the bleeding-edge GCC
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-proposed main restricted universe multiverse"
apt-get update

if [ "$GCC_VER" = "latest" ]; then
    # Dynamically find the latest GCC version available natively in apt (e.g. "15", "16")
    GCC_VER=$(apt-cache search "^gcc-[0-9]+$" | grep -oP "^gcc-[0-9]+" | sort -V | tail -n 1 | sed 's/gcc-//')
fi
echo "Found GCC version: $GCC_VER"

# Install latest GCC prioritizing the proposed repository using -t
apt-get install -y -t "${UBUNTU_CODENAME}-proposed" --no-install-recommends gcc-${GCC_VER} g++-${GCC_VER} libstdc++-${GCC_VER}-dev

# Remove the proposed repository so it doesn't affect subsequent non-GCC installs
add-apt-repository -y --remove "deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-proposed main restricted universe multiverse"

# Set default alternatives
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} ${GCC_VER}
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} ${GCC_VER}

# +-----------------------------+
# | CMake                       |
# +-----------------------------+
echo "Install CMake"
# pip install cmake --no-cache-dir --break-system-packages

CMAKE_VER="4.2.3"
echo "Downloading CMake ${CMAKE_VER}..."
wget -q "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.sh"

echo "Installing CMake..."
chmod +x cmake-${CMAKE_VER}-linux-x86_64.sh
./cmake-${CMAKE_VER}-linux-x86_64.sh --skip-license --prefix=/usr/local --exclude-subdir
rm cmake-${CMAKE_VER}-linux-x86_64.sh

# Install Powershell
# source /etc/os-release
# wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
# dpkg -i packages-microsoft-prod.deb
# rm packages-microsoft-prod.deb
# apt-get update
# apt-get install -y powershell


# Cleaning
echo "Cleanup"
# pip cache remove cmake
# pip cache purge
apt-get purge -y software-properties-common pip libmpfr-dev libgmp3-dev libmpc-dev xz-utils
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
