#!/usr/bin/env bash

# The master for this script exists in the Python '2.7' directory. Do
# not edit the version of this script found in other directories. When
# the version of the script in the Python '2.7' directory is modified,
# it must then be be copied into other directories. This is necessary as
# Docker when building an image cannot copy in a file from outside of
# the directory where the Dockerfile resides.

# Record everything that is run from this script so appears in logs.

set -x

# Ensure that any failure within this script causes this script to fail
# immediately. This eliminates the need to check individual statuses for
# anything which is run and prematurely exit. Note that the feature of
# bash to exit in this way isn't foolproof. Ensure that you heed any
# advice in:
#
#   http://mywiki.wooledge.org/BashFAQ/105
#   http://fvue.nl/wiki/Bash:_Error_handling
#
# and use best practices to ensure that failures are always detected.
# Any user supplied scripts should also use this failure mode.

set -eo pipefail

# Add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
groupadd -r compute
useradd -r -g compute compute
mkdir /home/compute
chown compute:compute /home/compute

# Ensure we have an up to date package index.

rm -rf /var/lib/apt/lists/* 

apt-get update

# Grab gosu for easy step-down from root
GOSU_VERSION=1.7
gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc"
gpg --verify /usr/local/bin/gosu.asc
rm /usr/local/bin/gosu.asc
chmod +x /usr/local/bin/gosu

# Install nginx to be able to serve content from this container

apt-get install -y nginx-light
rm -rf /etc/nginx/*.d
mkdir -p /etc/nginx/addon.d /etc/nginx/conf.d /etc/nginx/host.d /etc/nginx/nginx.d

# Create our standard directories:
#   /data/in : input data should go there
#   /data/out : output data should go there
#   /var/www/html : root for the HTML documentation which can be served when the container is executed in serve mode
mkdir -p /data/in /data/out /var/www/html/ /src
chown -R compute:compute /data/in /data/out /var/www/html/ /src
ln -s -t /var/www/html/ /src

# Install testthat package

install2.r --error testthat

# Cleanup of apt already performed in our install.r scripts

rm -rf /tmp/*
