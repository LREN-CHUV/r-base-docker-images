## Start with the official rocker image (lightweight Debian)
FROM hbpmip/r-base:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.2 \
      eu.humanbrainproject.category=R

COPY scripts/setup.sh /usr/local/bin/r-mip-docker-setup

ENV R_REPO=https://cran.rstudio.com/ \
    COMPUTE_IN=/data/in \
    COMPUTE_OUT=/data/out \
    SRC=/src

RUN /usr/local/bin/r-mip-docker-setup

# Copy our configuration of Nginx
COPY etc/nginx/ /etc/nginx/

VOLUME /data/in
VOLUME /data/out

COPY scripts/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
CMD ["compute"]
