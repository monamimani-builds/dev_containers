FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

ENV VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh