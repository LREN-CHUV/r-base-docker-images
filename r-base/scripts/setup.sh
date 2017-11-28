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


# Set a default user. Available via runtime flag `--user docker`
# Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
# User should also have & own a home directory (for rstudio or linked volumes to work properly).
useradd docker
mkdir /home/docker
chown docker:docker /home/docker
addgroup docker staff

# Ensure we have an up to date package index.

rm -rf /var/lib/apt/lists/*

apt-get update

# Install base required dependencies.
# This is still a slim install. If additional packages are needed based on users code, such as dependencies for new R packages,
# they should be installed by the user from the build hooks.

apt-get install -y --no-install-recommends \
        ed \
        less \
        locales \
        vim-tiny \
        wget \
        ca-certificates \
        fonts-texgyre \
        libpq-dev

# git will be removed later in this script

# Ensure that default language locale is set to a sane default of UTF-8.

echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen

locale-gen

LC_ALL=en_US.UTF-8
export LC_ALL

LANG=en_US.UTF-8
export LANG

/usr/sbin/update-locale LANG=$LANG

# Set up the directory where R installation will be put.

INSTALL_ROOT=/usr/local
export INSTALL_ROOT

BUILD_ROOT=/tmp/build
export BUILD_ROOT

mkdir -p $INSTALL_ROOT
mkdir -p $BUILD_ROOT

# Validate that package version details are set in the Dockerfile.

test ! -z "$R_BASE_VERSION" || exit 1
echo "Installing R version $R_BASE_VERSION..."

# To be safe, force the C compiler to be used to be the 64 bit compiler.

CC=x86_64-linux-gnu-gcc
export CC

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
apt-get update
apt-get install -y --no-install-recommends \
        r-cran-littler \
        "r-base-core=${R_BASE_VERSION}-*" \
        "r-base=${R_BASE_VERSION}-*" \
        "r-cran-mass" \
        "r-cran-matrix"

# Ensure that autoremove is not too greedy
apt-mark manual r-base-core

echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site
echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r
ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r

apt-get purge -y build-essential cpp cpp-5 dpkg-dev \
        g++ g++-5 gcc gcc-5 gfortran gfortran-5 perl-modules fonts-dejavu-core \

apt-get autoremove -y

# Create empty directory to be used as application directory.

mkdir -p /app

# Create empty directory to be used as the data directory. Ensure it is
# world writable but also has the sticky bit so only root or the owner
# can unlink any files. Needs to be world writable as we cannot be
# certain what uid application will run as.

mkdir -p /data
chmod 1777 /data

# Create empty directory to be used as the temporary runtime directory.
# Ensure it is world writable but also has the sticky bit so only root
# or the owner can unlink any files. Needs to be world writable as we
# cannot be certain what uid application will run as.

mkdir -p /.whiskey
chmod 1777 /.whiskey

/usr/local/bin/apt-cleanup.sh
