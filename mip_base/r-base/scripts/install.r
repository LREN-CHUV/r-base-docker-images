#!/usr/bin/env bash

# Wrapper for install.r that installs r-base-dev before executing the installation of R packages then removes
# r-base-dev to keep the image lean.

apt-get update
apt-get install -t unstable -y --no-install-recommends \
		r-base-dev=${R_BASE_VERSION}*

/usr/share/doc/littler/examples/install.r $@

apt-get purge -y build-essential cpp cpp-5 dpkg-dev \
	g++ g++-5 gcc gcc-5 gfortran gfortran-5 perl-modules fonts-dejavu-core

apt-get autoremove -y

rm -rf /tmp/downloaded_packages/ /tmp/*.rds
rm -rf /var/lib/apt/lists/*
rm -rf /var/lib/{apt,dpkg,cache,log}/
rm -rf /var/{cache,log}
