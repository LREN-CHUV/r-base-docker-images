#!/usr/bin/env bash

set -eo pipefail

apt-get update
apt-get install -t unstable -y --no-install-recommends \
        make \
		r-base-dev=${R_BASE_VERSION}*

R CMD install $@

apt-get purge -y build-essential cpp cpp-5 dpkg-dev make \
	g++ g++-5 gcc gcc-5 gfortran gfortran-5 perl-modules fonts-dejavu-core

rm -rf /tmp/downloaded_packages/ /tmp/*.rds

/usr/local/bin/apt-cleanup.sh
