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

# Core dev tools
apt-get install -y --no-install-recommends \
    ca-certificates git git-lfs ninja-build ssh \
    graphviz ccache cppcheck valgrind \
    zip unzip tar xz-utils binutils pkg-config curl gdb

# Install official Node.js binaries to avoid Debian node-* bloat (~150MB)
NODE_VER="latest"
if [ "$NODE_VER" = "latest" ]; then
    NODE_VER=$(curl -sS https://nodejs.org/dist/index.tab | awk '/^v[0-9]/ {print $1; exit}')
fi
echo "Downloading Node.js ${NODE_VER}..."
curl -fsSLO "https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-linux-x64.tar.xz"
tar -xf "node-${NODE_VER}-linux-x64.tar.xz" -C /usr/local --strip-components=1 --no-same-owner
rm -f "node-${NODE_VER}-linux-x64.tar.xz"
strip /usr/local/bin/node

# Install official Doxygen binary to avoid Ubuntu's libllvm21 dependency (~200MB bloat)
DOXYGEN_VER="latest"
if [ "$DOXYGEN_VER" = "latest" ]; then
    LATEST_DOXYGEN_URL=$(curl -w "%{url_effective}" -L -s -S https://github.com/doxygen/doxygen/releases/latest -o /dev/null)
    DOXYGEN_VER=$(basename "$LATEST_DOXYGEN_URL" | sed 's/^Release_//' | tr '_' '.')
fi
echo "Downloading Doxygen ${DOXYGEN_VER}..."
curl -fsSLO "https://doxygen.nl/files/doxygen-${DOXYGEN_VER}.linux.bin.tar.gz"
tar -xzf "doxygen-${DOXYGEN_VER}.linux.bin.tar.gz"
cp "doxygen-${DOXYGEN_VER}/bin/doxygen" /usr/local/bin/
rm -rf "doxygen-${DOXYGEN_VER}" "doxygen-${DOXYGEN_VER}.linux.bin.tar.gz"
strip /usr/local/bin/doxygen

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
