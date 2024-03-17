FROM ubuntu:jammy

# Setup ENV vars for vcpkg
ENV VCPKG_ROOT=/usr/local/vcpkg \
  VCPKG_DOWNLOADS=/usr/local/vcpkg-downloads \
  VCPKG_INSTALLATION_ROOT=$VCPKG_ROOT \
  PATH="${PATH}:${VCPKG_ROOT}"

COPY install-packages.sh /tmp/
RUN chmod +x /tmp/install-packages.sh \
  && ./tmp/install-packages.sh \
  && rm -f /tmp/install-packages.sh

# Persist Bash history for root
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && echo "$SNIPPET" >> "/root/.bashrc"

# Persist Bash history for non root user
ARG USERNAME=vscode
RUN useradd -s /bin/bash --gid $USERNAME -m $USERNAME && SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"