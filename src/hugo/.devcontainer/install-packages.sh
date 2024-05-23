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

if [ "$(id -u)" -ne 0 ]; then
    _log "error" 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

apk update 
#apk add --no-cache --upgrade apk-tools
apk add --no-cache --virtual build-deps jq
apk upgrade

apk add --no-cache git go
apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo

# Install Dart Sass
pushd /tmp/
wget -q -O - $(wget -q -O - 'https://api.github.com/repos/sass/dart-sass/releases/latest' | jq -r '.assets[] | select(.name | endswith("linux-x64.tar.gz")).browser_download_url') | tar -xvz -C "/usr/local/bin"
export PATH=/usr/local/bin/dart-sass:$PATH
popd

# Cleaning
echo "Cleanup"
apk del build-deps
apk cache clean
rm -rf /var/cache/apk/*

hugo version
go version