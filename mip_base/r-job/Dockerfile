# This Docker container layer is the base for workflow jobs executing R scripts.


FROM registry.federation.mip.hbp/mip_base/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN installGithub.r LREN-CHUV/hbpjdbcconnect@6fcc5e8 \
    && rm -rf /tmp/*
