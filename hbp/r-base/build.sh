#!/bin/sh -e
captain build
captain test

docker tag hbp/r-base registry.federation.mip.hbp/hbp/r-base
docker push registry.federation.mip.hbp/hbp/r-base
