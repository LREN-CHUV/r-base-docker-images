# This Docker container layer is the base for workflow jobs executing R scripts.


FROM hbpmip/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN exec installGithub.r LREN-CHUV/hbpjdbcconnect@4ce2c14 \
    && rm -rf /tmp/*
