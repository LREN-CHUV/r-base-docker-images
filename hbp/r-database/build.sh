#!/bin/sh -e
captain build
captain test

docker tag hbp/r-database registry.federation.mip.hbp/hbp/r-database
docker push registry.federation.mip.hbp/hbp/r-database
