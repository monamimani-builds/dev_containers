#!/usr/bin/env bash

set -e

#!/usr/bin/env bash

apt-get update 
apt-get upgrade -y
apt-get install -y docker

git config user.email "monamimani@gmail.com"
git config user.name "monamimani"

# Cleaning
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*