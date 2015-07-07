#!/bin/sh
docker run -i -t --rm \
  -e REQUEST_ID=002 \
  -v /home/ludovic/tmp:/log \
  hbp-federation/workflow /bin/bash
