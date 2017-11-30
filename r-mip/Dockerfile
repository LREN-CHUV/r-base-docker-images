FROM hbpmip/r-base-build:3.4.2-2 as r-build-env

FROM hbpmip/r-base:3.4.2-2

MAINTAINER Ludovic Claude <ludovic.claude@chuv.ch>

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV R_REPO=https://cran.rstudio.com/ \
    COMPUTE_IN=/data/in \
    COMPUTE_OUT=/data/out \
    COMPUTE_TMP=/tmp \
    ERROR_FILE=/data/out/errors.txt \
    OUTPUT_FILE=/data/out/output.txt \
    RESULT_TABLE=job_result \
    SRC=/src

COPY docker/setup.sh /usr/local/bin/r-mip-docker-setup
RUN /usr/local/bin/r-mip-docker-setup

# Copy our configuration of Nginx
COPY docker/etc/nginx/ /etc/nginx/
RUN /usr/sbin/nginx -t

VOLUME /data/in
VOLUME /data/out

COPY docker/docker-entrypoint.sh /
COPY docker/wrapper.R /src/

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
CMD ["compute"]

LABEL eu.humanbrainproject.version=0.5 \
      eu.humanbrainproject.category=R \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="hbpmip/r-base-build" \
      org.label-schema.description="R runtime adapted to work in MIP environment" \
      org.label-schema.url="https://github.com/LREN-CHUV/r-base-docker-images" \
      org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/LREN-CHUV/r-base-docker-images.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version="$VERSION" \
      org.label-schema.vendor="LREN CHUV" \
      org.label-schema.license="Apache2.0" \
      org.label-schema.docker.dockerfile="Dockerfile" \
      org.label-schema.schema-version="1.0"
