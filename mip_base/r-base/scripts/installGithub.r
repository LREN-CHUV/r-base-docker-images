#!/usr/bin/env bash

# Wrapper for installGithub.r that installs r-base-dev before executing the installation of R packages then removes
# r-base-dev to keep the image lean.

apt-get update
apt-get install -t unstable -y --no-install-recommends \
		r-base-dev=${R_BASE_VERSION}*

/usr/share/doc/littler/examples/installGithub.r $@

rm -rf /tmp/downloaded_packages/ /tmp/*.rds
apt-get purge -y build-essential cpp cpp-5 dpkg-dev \
	g++ g++-5 gcc gcc-5 gfortran gfortran-5 perl-modules fonts-dejavu-core

rm -rf /var/lib/apt/lists/*

apt-get autoremove -y
rm -rf /var/lib/{apt,dpkg,cache,log}/
rm -rf /var/{cache,log}
