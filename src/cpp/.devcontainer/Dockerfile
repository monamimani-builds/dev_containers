FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04
#SHELL ["/bin/bash", "-c"]

ENV VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT

RUN apt-get update && apt-get upgrade -y

RUN sudo apt-get install -y --no-install-recommends software-properties-common

RUN wget https://apt.kitware.com/kitware-archive.sh
RUN chmod +x kitware-archive.sh
RUN sudo ./kitware-archive.sh 
RUN sudo apt install -y cmake 

#RUN  pushd "$VCPKG_ROOT"
RUN  cd $VCPKG_ROOT
RUN  chown -R $(id -u):$(id -g) $PWD
RUN  git pull --ff-only
#RUN  popd
