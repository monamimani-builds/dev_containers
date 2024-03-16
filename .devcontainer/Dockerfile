FROM ubuntu:22.04 AS base

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh

# FROM scratch AS final

# COPY --from=base / /

# CMD ["/bin/bash"]