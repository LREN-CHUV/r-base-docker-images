## Start with the official rocker image (lightweight Debian)
FROM r-base:3.2.0

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
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

COPY etc/nginx/ /etc/nginx/

RUN mkdir -p /var/run/compute/{in,out} /var/www/html/ /src \
    && chown -R compute /var/run/compute /var/www/html/ /src \
    && ln -s -t /var/www/html/ /src

COPY .Rprofile /root/

ENV R_REPO http://stat.ethz.ch/CRAN/
ENV COMPUTE_IN /var/run/compute/in
ENV COMPUTE_OUT /var/run/compute/out
ENV SRC /src
VOLUME /var/run/compute/in
VOLUME /var/run/compute/out

## Install testthat package
RUN install2.r --error testthat \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
CMD ["compute"]
