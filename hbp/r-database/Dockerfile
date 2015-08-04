FROM registry.federation.mip.hbp/hbp/r-java:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R \
      eu.humanbrainproject.capability.odbc=true \
      eu.humanbrainproject.capability.jdbc.postgres=true

COPY downloads/* /usr/lib/R/libraries/

# TODO: add Denodo JDBC driver

# Install ODBC driver for Postgres
RUN apt-get update && apt-get install -y odbc-postgresql \
    && apt-get clean \
    && echo -n > /var/lib/apt/extended_states \
	&& rm -rf /var/lib/apt/lists/*

# install packages
RUN echo 'install.packages(c("RJDBC", "RODBC", "RODBCext"), dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R
