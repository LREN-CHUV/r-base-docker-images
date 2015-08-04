#!/bin/sh -e

if [ "$1" = 'compute' ]; then
	mkdir -p "$COMPUTE_IN" "$COMPUTE_OUT"
	chown -R compute "$COMPUTE_IN" "$COMPUTE_OUT"

	gosu compute /usr/bin/Rscript /src/main.R

elif [ "$1" = 'export' ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /src/* "$COMPUTE_OUT/"
elif [ "$1" = 'export-docs' ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /var/www/html/* "$COMPUTE_OUT/"
elif [ "$1" = 'serve' ]; then
	/usr/sbin/nginx
elif [ "$1" = 'shell' ]; then
	/bin/bash -i
fi
