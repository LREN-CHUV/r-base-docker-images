# This Docker container layer is the base for workflow jobs executing R scripts.


FROM hbpmip/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN exec installGithub.r LREN-CHUV/hbpjdbcconnect@96e8215 \
    && rm -rf /tmp/*
