# This Docker container layer is the base for workflow jobs executing R scripts.


FROM hbpmip/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN installGithub.r LREN-CHUV/hbpjdbcconnect@7bb3e5de \
    && rm -rf /tmp/*
