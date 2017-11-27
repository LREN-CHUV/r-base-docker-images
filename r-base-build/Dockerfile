FROM ubuntu:17.10

MAINTAINER "Ludovic Claude" ludovic.claude@chuv.ch

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
