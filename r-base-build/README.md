[![DockerHub](https://img.shields.io/badge/docker-hbpmip%r--base--build-008bb8.svg)](https://hub.docker.com/r/hbpmip/r-base-build/) [![ImageVersion](https://images.microbadger.com/badges/version/hbpmip/r-base-build.svg)](https://hub.docker.com/r/hbpmip/r-base-build/tags "hbpmip/r-base-build image tags") [![ImageLayers](https://images.microbadger.com/badges/image/hbpmip/r-base-build.svg)](https://microbadger.com/#/images/hbpmip/r-base-build "hbpmip/r-base-build on microbadger")

# Base image for R scripts

This base image attempts to remain close to rocker/r-base image but with much of the extraneous libraries (r-recommends, r-base-dev) removed to keep the size of the image small.

See discussion in https://github.com/rocker-org/rocker/pull/150, I hope that explain why I had to create a fork of r-base -- rocker is focused on creating a base image for development, I need a lean base image for distribution.

There is a drawback: to include a new R library, the install.r and similar scripts need to download gcc and other big packages, perform the installation then remove those packages to keep the image lean. This process is quite slow, so building on top of this base image takes time. Be patient! On the other hand, execution and distribution of the final image are optimized as much as possible.

## Usage

Use this image as part of a multistage build.

It is very useful to be able to perform the compilation in the build stage, then copy the resulting binaries to the target image.

By doing so, you can keep the size of the target image small as it will not include the heavy build dependencies (gcc and more)

Dockerfile
```dockerfile
  FROM hbpmip/r-base-build:3.4.2-1 as r-build-env

  RUN install.r my_lib

  FROM hbpmip/r-base:3.4.2-0

  COPY --from=r-build-env /usr/local/lib/R/site-libraries/my_lib/ /usr/local/lib/R/site-libraries/my_lib/

```
