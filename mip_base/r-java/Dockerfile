FROM registry.federation.mip.hbp/mip_base/r-libs:latest

# Initial code from https://github.com/cardcorp/card-rocker/tree/master/r-java
# MAINTAINER Gergely Daroczi <gergely.daroczi@card.com>
MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R

## Install Java 
RUN apt-get update \
    && apt-get install -y openjdk-8-jdk \
    && update-alternatives --display java \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && R CMD javareconf

## Install rJava package
RUN install2.r --error rJava \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN echo "LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/:/usr/lib/jvm/java-8-openjdk-amd64/lib/amd64/" >> /etc/environment \
    && echo "LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/:/usr/lib/jvm/java-8-openjdk-amd64/lib/amd64/" >> /home/docker/.profile
