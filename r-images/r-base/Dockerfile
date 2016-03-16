FROM debian:testing

MAINTAINER "Ludovic Claude" ludovic.claude@chuv.ch

ENV R_BASE_VERSION=3.2.4
ENV APT_PROXY_HOST=lab01560.intranet.chuv \
    APT_PROXY_URL=http://lab01560.intranet.chuv:3142

COPY scripts/apt-cleanup.sh /usr/local/bin/apt-cleanup.sh
COPY scripts/setup.sh /usr/local/bin/r-base-docker-setup
COPY scripts/install.r /usr/local/bin/install.r
COPY scripts/install2.r /usr/local/bin/install2.r
COPY scripts/installGithub.r /usr/local/bin/installGithub.r
COPY scripts/installPkg.sh /usr/local/bin/installPkg.sh

RUN /usr/local/bin/r-base-docker-setup

CMD ["R"]
