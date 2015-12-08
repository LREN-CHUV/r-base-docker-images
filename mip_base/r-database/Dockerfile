FROM registry.federation.mip.hbp/mip_base/r-java:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R \
      eu.humanbrainproject.capability.odbc=true \
      eu.humanbrainproject.capability.jdbc.postgres=true

# Install ODBC driver for Postgres
RUN apt-get update && apt-get install -y libodbc1 libiodbc2 libiodbc2-dev odbc-postgresql libmyodbc r-cran-rodbc \
    && /usr/local/bin/apt-cleanup.sh

ADD https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar /usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar /usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar
ADD http://guest:guest@hbps1.chuv.ch/community/share/_IT-tools/federation/drivers/vdp-jdbcdriver-core/denodo-vdp-jdbcdriver.jar /usr/lib/R/libraries/denodo-vdp-jdbcdriver.jar

# install packages
RUN install2.r --error RJDBC \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds
