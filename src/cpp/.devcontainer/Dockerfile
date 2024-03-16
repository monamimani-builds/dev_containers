FROM ubuntu:22.04

# Setup ENV vars for vcpkg
ENV VCPKG_ROOT=/usr/local/vcpkg \
    VCPKG_DOWNLOADS=/usr/local/vcpkg-downloads \
    VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT \
    PATH="${PATH}:${VCPKG_ROOT}"

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh
 