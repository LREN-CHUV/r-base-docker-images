#!/bin/sh
docker run -i -t --rm \
  -e REQUEST_ID=001 \
  -e COUNT_RESULTS_QUERY="select count(*) from results_linear_regression where request_id='001'" \
  -e EXPECTED_COUNT_RESULTS=2 \
  -e JDBC_DRIVER=org.postgresql.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar \
  -e JDBC_URL=jdbc:postgresql://lab01560.intranet.chuv:5432/DEMO \
  -e JDBC_USER=federation \
  -e JDBC_PASSWORD=HBP4thewin \
  -v /home/ludovic/tmp:/log \
  registry.federation.mip.hbp/hbp_federation/workflow /bin/bash
