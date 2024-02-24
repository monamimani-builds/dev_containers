#!/bin/bash

apt update
apt upgrade -y

#apt-get install -y --no-install-recommends software-properties-common

echo "------------------------------"
echo "Installing packages..."
echo "------------------------------"

pushd /tmp/
echo "Add CMake repo"
wget https://apt.kitware.com/kitware-archive.sh
chmod +x kitware-archive.sh
sudo ./kitware-archive.sh

popd
sudo apt update

echo "Install CMake"
sudo apt install -y cmake