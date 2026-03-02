#!/usr/bin/env bash
# Installs persistent apt packages that remain in the final image.
# This is the base layer - no temp deps, just tools we keep.

set -eux
export DEBIAN_FRONTEND=noninteractive

if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: Script must be run as root." 1>&2
    exit 1
fi

# Disable recommends/suggests globally for minimal installs
cat > /etc/apt/apt.conf.d/99norecommend << EOF
APT::Install-Recommends "false";
APT::Install-Suggests "false";
APT::Acquire::Queue-Mode "access";
Acquire::Queue-Worker::MaxQueue "10";
EOF

apt-get update
apt-get upgrade -y

# Core dev tools
apt-get install -y --no-install-recommends \
    git git-lfs ninja-build ssh npm \
    doxygen graphviz ccache cppcheck valgrind \
    zip unzip tar pkg-config curl gdb

# Purge any base-image leftovers that conflict with our custom installs
apt-get purge -y cmake 2>/dev/null || true
apt-get purge -y gcc-* 2>/dev/null || true
apt-get purge -y libstdc++-* 2>/dev/null || true
apt-get purge -y llvm-* 2>/dev/null || true
apt-get autoremove -y

apt-get clean -y
rm -rf /var/lib/apt/lists/*

# Remove docs and debug symbols to save space
rm -rf /usr/share/doc /usr/share/man /usr/share/locale \
       /usr/lib/debug

echo "Base packages installed:"
git --version
ninja --version
gdb --version | head -1
