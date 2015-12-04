# In this Docker container layer, we install some common libraries:
#
# * MASS
# * plyr
# * jsonlite
# * rjson
# * rjstat


FROM registry.federation.mip.hbp/mip_base/r-base:latest

MAINTAINER ludovic.claude54@gmail.com

RUN install2.r --error MASS plyr jsonlite rjson rjstat \
    && rm -rf /tmp/*
