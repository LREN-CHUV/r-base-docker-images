#!/bin/sh
# We need X11 for the graph to display.

# Bind mount your data
# assuming that current folder contains the data
$ docker run -v $(pwd):/home/user/data \
    -it --name analytics \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    hbp-desktop/r-interactive
