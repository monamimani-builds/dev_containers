FROM ubuntu:22.04

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh

# ENV VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT