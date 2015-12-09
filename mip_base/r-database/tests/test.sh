#!/bin/sh

docker run --rm \
  --link indb:db \
  -e JDBC_DRIVER=org.postgresql.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar \
  -e JDBC_URL=jdbc:postgresql://indb:5432/postgres \
  -e JDBC_USER=postgres \
  -e JDBC_PASSWORD=test \
  registry.federation.mip.hbp/mip_base/r-database-test test
