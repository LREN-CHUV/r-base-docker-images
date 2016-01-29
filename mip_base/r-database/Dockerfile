FROM hbpmip/r-java:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.capability.odbc=true \
      eu.humanbrainproject.capability.jdbc.postgres=true \
      eu.humanbrainproject.capability.jdbc.denodo=true

ADD https://jdbc.postgresql.org/download/postgresql-9.3-1103.jdbc41.jar /usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar
ADD https://jdbc.postgresql.org/download/postgresql-9.4-1201.jdbc41.jar /usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar
RUN wget --http-user guest --http-password guest -O /usr/lib/R/libraries/denodo-vdp-jdbcdriver.jar http://hbps1.chuv.ch/community/share/_IT-tools/federation/drivers/vdp-jdbcdriver-core/denodo-vdp-jdbcdriver.jar

COPY scripts/setup.sh /usr/local/bin/r-database-docker-setup

RUN /usr/local/bin/r-database-docker-setup
