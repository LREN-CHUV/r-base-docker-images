## Start with the official rocker image (lightweight Debian)
FROM r-base:3.2.2

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r compute && useradd -r -g compute compute

# grab gosu for easy step-down from root
# install nginx to be able to serve content from this container
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && echo "deb http://http.debian.net/debian jessie main" >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
    && apt-get install -y nginx-light \
    && rm -rf /etc/nginx/*.d \
    && mkdir -p /etc/nginx/addon.d /etc/nginx/conf.d /etc/nginx/host.d /etc/nginx/nginx.d \
    && apt-get autoremove -y \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/* /tmp/*

COPY etc/nginx/ /etc/nginx/

ENV R_REPO https://cran.rstudio.com/ \
    COMPUTE_IN /data/in \
    COMPUTE_OUT /data/out \
    SRC /src

# Create our standard directories:
#   /data/in : input data should go there
#   /data/out : output data should go there
#   /var/www/html : root for the HTML documentation which can be served when the container is executed in serve mode
# Install testthat package
RUN mkdir -p /data/in /data/out /var/www/html/ /src \
    && chown -R compute /data /var/www/html/ /src \
    && ln -s -t /var/www/html/ /src \
    && install2.r --error testthat \
    && rm -rf /tmp/*

VOLUME /data/in
VOLUME /data/out

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
CMD ["compute"]
