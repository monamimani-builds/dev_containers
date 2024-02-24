FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

ENV VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT

RUN apt-get update && apt-get upgrade -y

RUN sudo apt-get install -y --no-install-recommends software-properties-common

RUN wget https://apt.kitware.com/kitware-archive.sh
RUN chmod +x kitware-archive.sh
RUN sudo ./kitware-archive.sh 
RUN sudo apt install -y cmake 
# RUN pushd /tmp/ \
#   echo "Add CMake repo" \
#   wget https://apt.kitware.com/kitware-archive.sh \
#   chmod +x kitware-archive.sh \
#   sudo ./kitware-archive.sh 

#   popd \
#   sudo apt update \
#   \
#   echo "Install CMake" \
#   sudo apt install -y cmake 