FROM ubuntu:17.10

MAINTAINER "Ludovic Claude" ludovic.claude@chuv.ch

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    R_BASE_VERSION=3.4.2

COPY scripts/apt-cleanup.sh /usr/local/bin/apt-cleanup.sh
COPY scripts/setup.sh /usr/local/bin/r-base-docker-setup

RUN /usr/local/bin/r-base-docker-setup

RUN R -e "source('https://bioconductor.org/biocLite.R')" \
  && install2.r --error \
    --deps TRUE \
    tidyverse \
    dplyr \
    ggplot2

CMD ["R"]

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="hbpmip/r-base-build" \
      org.label-schema.description="R build environment" \
      org.label-schema.url="https://github.com/LREN-CHUV/r-base-docker-images" \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/LREN-CHUV/r-base-docker-images.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version="$VERSION" \
      org.label-schema.vendor="LREN CHUV" \
      org.label-schema.license="Apache2.0" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.schema-version="1.0"
