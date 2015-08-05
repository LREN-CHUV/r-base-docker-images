#!/bin/sh
# We need X11 for the graph to display.

# Allow docker user to access your X session
xhost +local:docker

# Bind mount your data
# assuming that current folder contains the data
docker run -v $(pwd):/home/docker/data \
    -i -t --rm --name analytics \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    registry.federation.mip.hbp/hbp_tools/r-interactive
