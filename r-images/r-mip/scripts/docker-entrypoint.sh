#!/bin/sh -e

if [ "$1" = "compute" ]; then
	mkdir -p "$COMPUTE_IN" "$COMPUTE_OUT"
	chown -R compute "$COMPUTE_IN" "$COMPUTE_OUT"

	gosu compute /usr/bin/Rscript /src/main.R
	exit $?

elif [ "$1" = "test" ]; then
	mkdir -p "$COMPUTE_IN" "$COMPUTE_OUT"
	chown -R compute "$COMPUTE_IN" "$COMPUTE_OUT"

	gosu compute /usr/bin/Rscript /src/tests/testthat.R
	exit $?

elif [ "$1" = "export" ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /src/* "$COMPUTE_OUT/"
elif [ "$1" = "export-docs" ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /var/www/html/* "$COMPUTE_OUT/"
elif [ "$1" = "serve" ]; then
	/usr/sbin/nginx
elif [ "$1" = "/bin/sh" ] | [ "$1" = "/bin/bash" ] ; then
	echo "** Please use 'shell' command instead of $1 **"
	/bin/bash -i
elif [ "$1" = "shell" ] ; then
	/bin/bash -i
elif [ "$1" = "R" ] ; then
	cd /src
	gosu compute /usr/bin/R
	exit $?
elif [ "$1" = "help" ] | [ "$1" = "-h" ] | [ "$1" = "--help" ] | [ "$1" = "" ] ; then
	echo "Usage:"
	echo
	echo "* As a standalone command:"
	echo "    docker run --rm -v /host-data/in:/data/in -v /host-data/out:/data/out <image name> <command>"
	echo "where command is one of:"
	echo "  - compute:     Launch the computation."
	echo "  - test:        Execute the unit tests located in the /src/tests/ directory."
	echo "  - export:      Export the sources into /data/out/ directory which should have been mounted on the host"
	echo "  - export-docs: Export the documentation into /data/out/ directory which should have been mounted on the host"
	echo "  - help:        Print this help message"
	echo
	echo "* As a server:"
	echo "    docker run -d -p 8080:80 <image name> <command>"
	echo "where command is one of:"
	echo "  - serve:       Turn this container into a documentation server."
	echo
	echo "* With an interactive shell:"
	echo "    docker run -i -t --rm -v /host-data/in:/data/in -v /host-data/out:/data/out <image name> <command>"
	echo "where command is one of:"
	echo "  - shell:       Launch the command line shell"
	echo "  - R:           Launch R interactive shell"
fi
