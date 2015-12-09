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

rm -r /var/lib/apt/lists/* 

# In our environment, attempt to use the APT proxy (apt-cacher)
ping -c 3 -w 3 lab01560.intranet.chuv \
    && echo 'Acquire::http { Proxy "http://lab01560.intranet.chuv:3142"; };' >> /etc/apt/apt.conf.d/01proxy \
    && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

apt-get update

# Install all the dependencies that we need.
# This is still a slim install. If additional packages are needed based on users code, such as dependencies for new R packages,
# they should be installed by the user from the build hooks.

apt-get install -y --no-install-recommends \
        ed \
        less \
        locales \
        vim-tiny \
        wget \
        curl \
        libcurl4-openssl-dev \
        ca-certificates

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

# Use Debian unstable via pinning -- new style via APT::Default-Release

echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list
echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

# Validate that package version details are set in the Dockerfile.

test ! -z "$R_BASE_VERSION" || exit 1

# To be safe, force the C compiler to be used to be the 64 bit compiler.

CC=x86_64-linux-gnu-gcc
export CC

## Now install R and littler, and create a link for littler in /usr/local/bin
## Also set a default CRAN repo, and make sure littler knows about it too
apt-get update
apt-get install -t unstable -y --no-install-recommends \
        littler/unstable \
        r-base-core=${R_BASE_VERSION}* \
        r-base=${R_BASE_VERSION}* \
        r-recommended=${R_BASE_VERSION}*

# Ensure that autoremove is not too greedy
apt-mark manual r-base-core

echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site
echo 'source("/etc/R/Rprofile.site")' >> /etc/littler.r
ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r

# docopt, httr , withr and memoise are used by littler
install.r docopt httr withr memoise

# Hack our version of installGithub.r
# installGithub.r depends on devtools, and that brings up tons of dependencies which are not trivial to clear
# Instead, we embbed a minimal set of code from devtools and a few dependencies defiend above.

cat <<EOF > /usr/local/bin/_installGithub.r
#!/usr/bin/env r
#
# A simple example to install one or more packages from GitHub
#
# Copyright (C) 2014 - 2015  Carl Boettiger and Dirk Eddelbuettel
#
# Released under GPL (>= 2)

EOF

apt-get install -y git

mkdir -p /tmp/devtools

cd /tmp/devtools

git clone https://github.com/hadley/devtools.git
cd devtools
git checkout v1.9.1

cd R

for f in utils package-env reload rtools R cran parse-deps deps has-devel system decompress git package install install-remote github install-github
cat <<EOF >> /usr/local/bin/_installGithub.r

##
## Code copied from https://raw.githubusercontent.com/hadley/devtools/master/R/$f.r
##

EOF

cat $f.r >> /usr/local/bin/_installGithub.r

cd /
rm -rf /tmp/devtools

apt-get remove -y git

cat <<EOF >> /usr/local/bin/_installGithub.r

## load docopt and devtools from CRAN
suppressMessages(library(docopt))       # we need docopt (>= 0.3) as on CRAN

## configuration for docopt
doc <- "Usage: installGithub.r [-h] [-d DEPS] REPOS...

-d --deps DEPS      Install suggested dependencies as well? [default: NA]
-h --help           show this help text

where REPOS... is one or more GitHub repositories.

Examples:
  installGithub.r RcppCore/RcppEigen

installGithub.r is part of littler which brings 'r' to the command-line.
See http://dirk.eddelbuettel.com/code/littler.html for more information.
"

## docopt parsing
opt <- docopt(doc)
if (opt$deps == "TRUE" || opt$deps == "FALSE") {
    opt$deps <- as.logical(opt$deps)
} else if (opt$deps == "NA") {
    opt$deps <- NA
}

invisible(sapply(opt$REPOS, function(r) install_github(r, dependencies = opt$deps)))
EOF

chmod +x /usr/local/bin/_installGithub.r

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
