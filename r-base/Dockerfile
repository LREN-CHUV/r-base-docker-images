FROM hbpmip/r-base-build:3.4.2-1 as r-build-env

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

COPY --from=r-build-env /usr/local/lib/R/site-library/DBI/ /usr/local/lib/R/site-library/DBI/
COPY --from=r-build-env /usr/local/lib/R/site-library/RPostgreSQL/ /usr/local/lib/R/site-library/RPostgreSQL/
COPY --from=r-build-env /usr/local/lib/R/site-library/jsonlite/ /usr/local/lib/R/site-library/jsonlite/
COPY --from=r-build-env /usr/local/lib/R/site-library/magrittr/ /usr/local/lib/R/site-library/magrittr/
COPY --from=r-build-env /usr/local/lib/R/site-library/whisker/ /usr/local/lib/R/site-library/whisker/
COPY --from=r-build-env /usr/local/lib/R/site-library/yaml/ /usr/local/lib/R/site-library/yaml/

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
