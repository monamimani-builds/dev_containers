FROM mcr.microsoft.com/devcontainers/base:alpine


COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
    && ./tmp/install-packages.sh \
    && rm -f /tmp/install-packages.sh