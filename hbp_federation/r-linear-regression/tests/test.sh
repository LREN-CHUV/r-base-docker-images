#!/bin/sh -e

docker run --rm --link test-postgres:postgres \
  -e REQUEST_ID=001 \
  -e JDBC_DRIVER=org.postgresql.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar \
  -e JDBC_URL=jdbc:postgresql://postgres:5432/postgres \
  -e JDBC_USER=postgres \
  -e JDBC_PASSWORD=test \
  -e INPUT_TABLE=test.results_linear_regression \
  -e RESULT_TABLE=test.federation_results_linear_regression \
  registry.federation.mip.hbp/hbp_federation/r-linear-regression-test test
