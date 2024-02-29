FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04
#SHELL ["/bin/bash", "-c"]

ENV VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT

RUN apt-get update && apt-get upgrade -y \
    && sudo apt-get install -y --no-install-recommends software-properties-common

RUN cd /tmp \
    && wget https://apt.kitware.com/kitware-archive.sh \
    && chmod +x kitware-archive.sh \
    && sudo ./kitware-archive.sh \
    && sudo apt install -y cmake \
    && cd /

#RUN pushd "$VCPKG_ROOT"
RUN cd $VCPKG_ROOT \
    && ls -al \
    #&& git config --global --add safe.directory "$VCPKG_ROOT" 
    && chown -R $(id -u):$(id -g) $PWD \
    && git pull --ff-only \
    #&& popd
    && cd /