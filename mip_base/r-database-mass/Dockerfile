FROM registry.federation.mip.hbp/mip_base/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN install2.r --error MASS \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
