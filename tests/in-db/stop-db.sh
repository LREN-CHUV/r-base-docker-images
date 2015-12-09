#!/bin/bash -e

if groups $USER | grep &>/dev/null '\bdocker\b'; then
    DOCKER="docker"
else
    DOCKER="sudo docker"
fi

$DOCKER stop indb > /dev/null
$DOCKER rm indb > /dev/null
