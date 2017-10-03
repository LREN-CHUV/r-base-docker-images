#!/bin/sh
# We need X11 for the graph to display.

WORK_DIR=$1
shift

if [ "$WORK_DIR" = "" ]; then
	WORK_DIR=$(pwd)/data
fi

mkdir -p $WORK_DIR
sudo chmod -R a+rw $WORK_DIR

# Allow docker user to access your X session
xhost +local:docker

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

# Bind mount your data
# assuming that current folder contains the data
$DOCKER run -v $WORK_DIR:/home/docker/data:rw \
    -i -t --rm --name r-interactive \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=unix$DISPLAY \
    registry.federation.mip.hbp/mip_tools/r-interactive $@

sudo chown -R $USER:$USER $WORK_DIR
