#!/bin/sh -e

if [ "$1" = 'compute' ]; then
	shift
	mkdir -p "$COMPUTE_IN" "$COMPUTE_OUT"
	chown -R compute "$COMPUTE_IN" "$COMPUTE_OUT"

	gosu compute "/run.sh $@"

elif [ "$1" = 'export' ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /src/* "$COMPUTE_OUT/"
elif [ "$1" = 'export-docs' ]; then
	# Assume that $COMPUTE_OUT is mounted on the host directory
	cp -R /var/www/html/* "$COMPUTE_OUT/"
elif [ "$1" = 'serve' ]; then
	gosu compute "nginx -g daemon off"
fi
