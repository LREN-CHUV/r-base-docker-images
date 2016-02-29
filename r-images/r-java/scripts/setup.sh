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

## Install Java 

apt-get update

apt-get install -y --no-install-recommends openjdk-8-jdk

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

exec install2.r --error rJava

/usr/local/bin/apt-cleanup.sh

rm -rf /tmp/downloaded_packages/ /tmp/*.rds
