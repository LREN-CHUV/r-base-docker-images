## Start with the official rocker image (lightweight Debian)
FROM r-base:3.2.0

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R

COPY .Rprofile /root/

## Deal with the proxy
ENV http_proxy http://PROXY:8080/
ENV R_REPO http://stat.ethz.ch/CRAN/

## Install testthat package
RUN install2.r --error testthat \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
