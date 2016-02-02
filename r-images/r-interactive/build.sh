#!/bin/bash -e

if pgrep -lf sshuttle > /dev/null ; then
  echo "sshuttle detected. Please close this program as it messes with networking and prevents jars to be downloaded."
  exit 1
fi

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  CAPTAIN="captain"
else
  CAPTAIN="sudo captain"
fi

$CAPTAIN build
