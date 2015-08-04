#!/bin/sh

docker run --rm --link test-postgres:postgres \
  -e REQUEST_ID=001 \
  -e JDBC_DRIVER=org.postgresql.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar \
  -e JDBC_URL=jdbc:postgresql://postgres:5432/test \
  -e JDBC_USER=postgres \
  -e JDBC_PASSWORD=test \
  registry.federation.mip.hbp/hbp_fedeartion/r-linear-regression
