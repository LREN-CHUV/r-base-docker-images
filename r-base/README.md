[![DockerHub](https://img.shields.io/badge/docker-hbpmip%r--base-008bb8.svg)](https://hub.docker.com/r/hbpmip/r-base/) [![ImageVersion](https://images.microbadger.com/badges/version/hbpmip/r-base.svg)](https://hub.docker.com/r/hbpmip/r-base/tags "hbpmip/r-base image tags") [![ImageLayers](https://images.microbadger.com/badges/image/hbpmip/r-base.svg)](https://microbadger.com/#/images/hbpmip/r-base "hbpmip/r-base on microbadger")

# Base image for R scripts

This base image attempts to remain close to rocker/r-base image but with much of the extraneous libraries (r-recommends, r-base-dev) removed to keep the size of the image small.

See discussion in https://github.com/rocker-org/rocker/pull/150, I hope that explain why I had to create a fork of r-base -- rocker is focused on creating a base image for development, I need a lean base image for distribution.

There is a drawback: you cannot install a new R library using this base image. Instead, you need to:

1. Use Dockerfile with multistage build
2. In the first build stage, inherit from hbpmip/r-base-build image and install the library
3. In the second build stage, inherit from hbpmip/r-base and copy the binaries of the library located under /usr/local/lib/R/site-libraries/ to this image.

Dockerfile
```dockerfile
  FROM hbpmip/r-base-build:3.4.2-1 as r-build-env

  RUN install.r my_lib

  FROM hbpmip/r-base:3.4.2-0

  COPY --from=r-build-env /usr/local/lib/R/site-libraries/my_lib/ /usr/local/lib/R/site-libraries/my_lib/

```
