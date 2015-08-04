FROM registry.federation.mip.hbp/hbp/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN install2.r --error MASS \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
