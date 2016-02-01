# In this Docker container layer, we install some common libraries:
#
# * plyr
# * jsonlite
# * rjson
# * rjstat
#
# Other libraries are already present from r-recommends package such as:
# * MASS
# * Matrix
# * cluster
# * foreign
# * rpart


FROM hbpmip/r-mip:latest

MAINTAINER ludovic.claude54@gmail.com

RUN install2.r --error plyr jsonlite rjson rjstat \
    && rm -rf /tmp/*
