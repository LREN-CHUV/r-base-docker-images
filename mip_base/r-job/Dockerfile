# This Docker container layer is the base for workflow jobs executing R scripts.


FROM registry.federation.mip.hbp/mip_base/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN installGithub.r LREN-CHUV/hbpjdbcconnect@fb54072 \
    && rm -rf /tmp/*
