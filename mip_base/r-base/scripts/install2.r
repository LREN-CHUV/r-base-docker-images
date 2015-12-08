#!/usr/bin/env bash

set -eo pipefail

# Wrapper for install2.r that installs r-base-dev before executing the installation of R packages then removes
# r-base-dev to keep the image lean.

apt-get update
apt-get install -t unstable -y --no-install-recommends \
        make \
		r-base-dev=${R_BASE_VERSION}*

/usr/share/doc/littler/examples/install2.r $@

apt-get purge -y build-essential cpp cpp-5 dpkg-dev make \
	g++ g++-5 gcc gcc-5 gfortran gfortran-5 perl-modules fonts-dejavu-core

rm -rf /tmp/downloaded_packages/ /tmp/*.rds

/usr/local/bin/apt-cleanup.sh
