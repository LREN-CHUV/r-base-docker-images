# This Docker container layer is the base for workflow jobs executing R scripts.


FROM registry.federation.mip.hbp/mip_base/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

COPY downloads/hbpjdbcconnect_0.0.0.9000_R_x86_64-pc-linux-gnu.tar.gz /tmp/hbpjdbcconnect.tar.gz

RUN R CMD INSTALL /tmp/hbpjdbcconnect.tar.gz \
    && rm -rf /tmp/*
