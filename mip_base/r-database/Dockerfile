FROM registry.federation.mip.hbp/mip_base/r-java:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R \
      eu.humanbrainproject.capability.odbc=true \
      eu.humanbrainproject.capability.jdbc.postgres=true

# Install ODBC driver for Postgres
RUN apt-get update && apt-get install -y libodbc1 libiodbc2 libiodbc2-dev odbc-postgresql libmyodbc r-cran-rodbc \
    && apt-get autoremove -y \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

COPY downloads/*.jar /usr/lib/R/libraries/

# install packages
RUN install2.r --error RJDBC \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
