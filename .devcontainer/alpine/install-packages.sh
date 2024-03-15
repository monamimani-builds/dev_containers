#!/usr/bin/env bash

set -e

apk update 
apk add --upgrade apk-tools
echo "upgrade"
apk upgrade
echo "add"
apk add --upgrade \
    git \
    bash \
    mandoc \
    curl \
    grep \
    sudo \
    docker \


# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

USERNAME=vscode
USER_UID=1000
USER_GID=1000
addgroup --gid $USER_GID $USERNAME
adduser -s /bin/bash --uid $USER_UID -G $USERNAME --disabled-password $USERNAME

echo vscode ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
chmod 0440 /etc/sudoers.d/$USERNAME

git config user.email "monamimani@gmail.com"
git config user.name "monamimani"

# Cleaning
apk cache clean
rm -rf /var/cache/apk/*