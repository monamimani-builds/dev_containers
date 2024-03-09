#!/usr/bin/env bash

apt-get update 
apt-get upgrade -y
sudo apt-get install -y --no-install-recommends software-properties-common

pushd /tmp/
wget https://apt.kitware.com/kitware-archive.sh
chmod +x kitware-archive.sh
sudo ./kitware-archive.sh
sudo apt install -y cmake
popd

# vcpkg: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
#RUN pushd "$VCPKG_ROOT"
pushd $VCPKG_ROOT
#git config --global --add safe.directory "$VCPKG_ROOT" 
#chown -R $(id -u):$(id -g) $PWD
git pull --ff-only
bootstrap-vcpkg.sh
vcpkg x-update-baseline --dry-run
popd



# Cleaning
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*