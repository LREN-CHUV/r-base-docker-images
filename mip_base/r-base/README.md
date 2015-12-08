
# Base image for R scripts

This base image attempts to remain close to rocker/r-base image but with much of the extraneous libraries (r-recommends, r-base-dev) removed to keep the size of the image small.

See discussion in https://github.com/rocker-org/rocker/pull/150, I hope that explain why I had to create a fork of r-base -- rocker is focused on creating a base image for development, I need a lean base image for distribution.
