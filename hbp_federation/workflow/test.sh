#!/bin/sh
docker run -i -t --rm \
  -e REQUEST_ID=002 \
  -e COUNT_RESULTS_QUERY="select count(*) from results_linear_regression where request_id='001'" \
  -e EXPECTED_COUNT_RESULTS=2 \
  -e JDBC_DRIVER=com.denodo.vdp.jdbc.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/denodo-vdp-jdbcdriver.jar \
  -e JDBC_URL=jdbc:vdb://lab01560.intranet.chuv:9999/analytics \
  -e JDBC_USER=analytics \
  -e JDBC_PASSWORD="HBP\=neuroinfo" \
  --net=bridge \
  registry.federation.mip.hbp/hbp_federation/workflow /bin/bash
