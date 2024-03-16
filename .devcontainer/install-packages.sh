#!/usr/bin/env bash

set -e

apt-get update 
apt-get -y upgrade
apt-get -y install --no-install-recommends git apt-transport-https curl ca-certificates pigz iptables gnupg2 dirmngr wget jq

# Cleaning
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*