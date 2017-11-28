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

# Ensure we have an up to date package index.

rm -rf /var/lib/apt/lists/*

# In our environment, attempt to use the APT proxy (apt-cacher)
ping -c 3 -i 0 -w 2 lab01560.intranet.chuv \
    && echo 'Acquire::http { Proxy "http://lab01560.intranet.chuv:3142"; };' >> /etc/apt/apt.conf.d/01proxy \
    && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

apt-get update

GCC_VERSION="4:5.3.1-1"
CURL_VERSION="7.47.0-1"

# Fix the versions to ensure reproducible builds.
apt-get install -y --force-yes \
        curl=$CURL_VERSION \
        libcurl3=$CURL_VERSION \
        libcurl4-openssl-dev=$CURL_VERSION \
        openssl \
        libssl-dev \
        libxml2-dev \
        subversion \
        git

# Documentation support
apt-get install -y --force-yes \
        pandoc \
        texinfo \
        texlive-base \
        texlive-extra-utils \
        texlive-fonts-extra \
        texlive-fonts-recommended \
        texlive-generic-recommended \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        fonts-roboto \
        fonts-roboto-hinted

apt-get install -y --no-install-recommends openjdk-8-jdk
