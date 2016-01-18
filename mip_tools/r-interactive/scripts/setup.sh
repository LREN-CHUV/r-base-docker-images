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
ping -c 3 -w 3 lab01560.intranet.chuv \
    && echo 'Acquire::http { Proxy "http://lab01560.intranet.chuv:3142"; };' >> /etc/apt/apt.conf.d/01proxy \
    && echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

apt-get update

GCC_VERSION="4:5.3.1-1"
CURL_VERSION="7.46.0-1"

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

## <r-libs + dev tools>

# install packages also installed in r-libs plus other nice tools for development
install2.r --error devtools roxygen2 testthat plyr jsonlite rjson rjstat knitr rmarkdown rstudioapi ggplot2 \
        reshape2 RColorBrewer scales gridBase wesanderson formatR lintr sjPlot

## </r-libs + dev tools>

## <r-java>

## Force openjdk-8 to be the default Java installation for rJava

update-alternatives --display java
echo "LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/:/usr/lib/jvm/java-8-openjdk-amd64/lib/amd64/" >> /etc/environment
echo "LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/:/usr/lib/jvm/java-8-openjdk-amd64/lib/amd64/" >> /home/docker/.profile
ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-java

apt-get install -t unstable -y --no-install-recommends \
        make \
		r-base-dev=${R_BASE_VERSION}*

R CMD javareconf


## Install rJava package

install2.r --error rJava

## </r-java>

## <r-database>

# Install ODBC driver for Postgres
apt-get install -y libodbc1 libiodbc2 libiodbc2-dev odbc-postgresql libmyodbc r-cran-rodbc

chmod a+r /usr/lib/R/libraries/*

# install packages
install2.r --error RJDBC \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## </r-database>

## <r-job>

installGithub.r LREN-CHUV/hbpjdbcconnect@ea7d575c

## </r-job>

# Cleanup

rm -rf /tmp/downloaded_packages/ /tmp/*.rds

apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*


# Create empty directory to be used as the data directory. Ensure it is
# world writable but also has the sticky bit so only root or the owner
# can unlink any files. Needs to be world writable as we cannot be
# certain what uid application will run as.

mkdir -p /data
chmod 1777 /data
