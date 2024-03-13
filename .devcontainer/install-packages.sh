#!/usr/bin/env bash

apk update 
apk upgrade -y



# Cleaning
apk autoremove -y
apk cache clean
rm -rf /var/cache/apk/*