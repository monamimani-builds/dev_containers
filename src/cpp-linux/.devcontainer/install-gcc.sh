#!/usr/bin/env bash
# Self-contained GCC layer.
# Installs temp deps (software-properties-common, gpg-agent), adds the
# ubuntu-proposed repo for bleeding-edge GCC, installs, strips, then
# purges temp deps and the proposed repo.

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

# Temp deps needed only during this layer
apt-get update
apt-get install -y --no-install-recommends software-properties-common gpg-agent

source /etc/os-release
UBUNTU_CODENAME=$VERSION_CODENAME

# Add the proposed repository for the bleeding-edge GCC
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-proposed main restricted universe multiverse"
apt-get update

GCC_VER="latest"
if [ "$GCC_VER" = "latest" ]; then
    # Dynamically find the latest GCC version available in apt
    GCC_VER=$(apt-cache search "^gcc-[0-9]+$" | grep -oP "^gcc-[0-9]+" | sort -V | tail -n 1 | sed 's/gcc-//')
fi
echo "Found GCC version: $GCC_VER"

apt-get install -y -t "${UBUNTU_CODENAME}-proposed" --no-install-recommends \
    gcc-${GCC_VER} g++-${GCC_VER} libstdc++-${GCC_VER}-dev

# Remove the proposed repository to avoid polluting future layers
add-apt-repository -y --remove "deb http://archive.ubuntu.com/ubuntu ${UBUNTU_CODENAME}-proposed main restricted universe multiverse"

# Register as default gcc/g++
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VER} ${GCC_VER}
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VER} ${GCC_VER}

echo "Stripping GCC binaries and libraries..."
strip /usr/bin/gcc-${GCC_VER} /usr/bin/g++-${GCC_VER} > /dev/null 2>&1 || true
find /usr/libexec/gcc/ -type f -executable -exec strip {} \; > /dev/null 2>&1 || true
find /usr/lib/gcc/ -name "*.so*" -type f -exec strip {} \; > /dev/null 2>&1 || true
strip /usr/lib/x86_64-linux-gnu/libstdc++.so* /usr/lib/x86_64-linux-gnu/libasan.so* /usr/lib/x86_64-linux-gnu/libubsan.so* /usr/lib/x86_64-linux-gnu/libtsan.so* > /dev/null 2>&1 || true

# Purge temp deps
apt-get purge -y software-properties-common gpg-agent
apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/*

echo "GCC ${GCC_VER} installed:"
gcc --version
g++ --version
