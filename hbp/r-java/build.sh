#!/bin/sh -e
captain build
captain test

docker tag hbp/r-java registry.federation.mip.hbp/hbp/r-java || true
docker push registry.federation.mip.hbp/hbp/r-java
