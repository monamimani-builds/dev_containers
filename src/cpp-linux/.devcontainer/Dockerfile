FROM ubuntu:resolute

# Setup ENV vars for vcpkg
ENV VCPKG_ROOT=/usr/local/vcpkg
ENV VCPKG_DOWNLOADS=/usr/local/vcpkg-downloads
ENV VCPKG_INSTALLATION_ROOT=${VCPKG_ROOT}
ENV PATH="${PATH}:${VCPKG_ROOT}"

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /tmp

# Layer 1: Base apt packages (git, ninja, gdb, ccache, etc.)
COPY install-base.sh .
RUN chmod +x ./install-base.sh && ./install-base.sh && rm -f ./install-base.sh

# Layer 2: LLVM (tarball download + prune + alternatives)
COPY install-llvm.sh .
RUN chmod +x ./install-llvm.sh && ./install-llvm.sh && rm -f ./install-llvm.sh

# Layer 3: GCC (from ubuntu-proposed)
COPY install-gcc.sh .
RUN chmod +x ./install-gcc.sh && ./install-gcc.sh && rm -f ./install-gcc.sh

# Layer 4: CMake (binary installer)
COPY install-cmake.sh .
RUN chmod +x ./install-cmake.sh && ./install-cmake.sh && rm -f ./install-cmake.sh

# Layer 5: vcpkg
COPY install-vcpkg.sh .
RUN chmod +x ./install-vcpkg.sh \
  && ./install-vcpkg.sh ${USERNAME}\
  && rm -f ./install-vcpkg.sh

# Persist Bash history for root
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && echo "$SNIPPET" >> "/root/.bashrc"

# Persist Bash history for non root user
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && chown -R $USERNAME /commandhistory \
    && echo "$SNIPPET" >> "/home/$USERNAME/.bashrc"

# [Optional] Set the default user. Omit if you want to keep the default as root.
#USER $USERNAME