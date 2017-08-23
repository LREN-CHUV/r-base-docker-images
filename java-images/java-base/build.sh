#!/usr/bin/env bash
set -e

if [[ $NO_SUDO || -n "$CIRCLECI" ]]; then
  DOCKER="docker"
  CAPTAIN="captain"
elif groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER="docker"
  CAPTAIN="captain"
else
  DOCKER="sudo docker"
  CAPTAIN="sudo captain"
fi

$DOCKER pull openjdk:8u131-jre-alpine
BUILD_DATE=$(date -Iseconds) \
  VCS_REF=$(git describe --tags --dirty) \
  VERSION=$(git describe --tags --dirty) \
  $CAPTAIN build
#$CAPTAIN test
