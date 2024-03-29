#!/usr/bin/env bash

set -eux

# vcpkg: https://github.com/microsoft/vcpkg/blob/master/README.md#quick-start-unix
mkdir -p "${VCPKG_ROOT}"
mkdir -p "${VCPKG_DOWNLOADS}"
pushd $VCPKG_ROOT
SHALLOW_CLONE_DATE=$(date -d "-1 years" +%s)
git clone \
    --depth=1 \
    -c core.eol=lf \
    -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    https://github.com/microsoft/vcpkg .

    #--shallow-since=${SHALLOW_CLONE_DATE} \
    # --single-branch \
    # --branch=master \
    # --no-tags \

git config --system --add safe.directory "$VCPKG_ROOT" 
git fetch --unshallow
git pull --ff-only
bootstrap-vcpkg.sh
popd

# Add to bashrc/zshrc files for all users.
updaterc() {
    _log "info" "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >>/etc/bash.bashrc
    fi
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >>/etc/zsh/zshrc
    fi
}

# Add vcpkg to PATH
updaterc "$(cat << EOF
export VCPKG_ROOT="${VCPKG_ROOT}"
if [[ "\${PATH}" != *"\${VCPKG_ROOT}"* ]]; then export PATH="\${PATH}:\${VCPKG_ROOT}"; fi
EOF
)"

# Enable tab completion for bash and zsh
VCPKG_FORCE_SYSTEM_BINARIES=1 su "vscode" -c "${VCPKG_ROOT}/vcpkg integrate bash"
VCPKG_FORCE_SYSTEM_BINARIES=1 su "root" -c "${VCPKG_ROOT}/vcpkg integrate bash"