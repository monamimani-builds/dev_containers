#!/usr/bin/env bash

set -eux

# log with color
_log() {
    local level=$1
    local msg=${*:2}

    _preset="clear"
    case "$level" in
    "red" | "r" | "error")
        _preset='\033[31m'
        ;;
    "green" | "g" | "success")
        _preset='\033[32m'
        ;;
    "yellow" | "y" | "warning" | "warn")
        _preset='\033[33m'
        ;;
    "blue" | "b" | "info")
        _preset='\033[34m'
        ;;
    "clear" | "c")
        _preset='\033[0m'
        ;;
    esac

    echo -e "$_preset["${level^^}"]:\033[0m $msg" 1>&2
}

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

USERNAME=$1
# Enable tab completion for bash
VCPKG_FORCE_SYSTEM_BINARIES=1 su "${USERNAME}" -c "${VCPKG_ROOT}/vcpkg integrate bash"
VCPKG_FORCE_SYSTEM_BINARIES=1 su "root" -c "${VCPKG_ROOT}/vcpkg integrate bash"