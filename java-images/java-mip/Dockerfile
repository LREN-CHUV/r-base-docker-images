FROM hbpmip/java-base:latest

MAINTAINER arnaud@ahead-solutions.ch

LABEL eu.humanbrainproject.version=0.2 \
      eu.humanbrainproject.category=Java

COPY scripts/setup.sh /usr/local/bin/java-mip-docker-setup

ENV COMPUTE_IN=/data/in \
    COMPUTE_OUT=/data/out \
    COMPUTE_TMP=/tmp \
    ERROR_FILE=/data/out/errors.txt \
    OUTPUT_FILE=/data/out/output.txt \
    SRC=/src

RUN /usr/local/bin/java-mip-docker-setup

# Copy our configuration of Nginx
COPY etc/nginx/ /etc/nginx/

VOLUME /data/in
VOLUME /data/out

COPY scripts/docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
CMD ["compute"]
