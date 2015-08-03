#!/bin/sh -e
captain build
captain test

docker tag hbp/r-database-mass registry.federation.mip.hbp/hbp/r-database-mass
docker push registry.federation.mip.hbp/hbp/r-database-mass
