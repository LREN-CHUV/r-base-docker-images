#!/bin/sh
docker run -i -t --rm \
  -e REQUEST_ID=002 \
  -e COUNT_RESULTS_QUERY="select count(*) from analytics.federation_results_linear_regression where request_id='002'" \
  -e EXPECTED_COUNT_RESULTS=2 \
  -e JDBC_DRIVER=com.denodo.vdp.jdbc.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/denodo-vdp-jdbcdriver.jar \
  -e JDBC_URL=jdbc:vdb://lab01560.intranet.chuv:9999/federation_sandbox \
  -e JDBC_USER=admin \
  -e JDBC_PASSWORD=admin \
  --net=bridge \
  --dns 155.105.251.102 --dns 155.105.251.86 \
  registry.federation.mip.hbp/hbp_federation/workflow /bin/bash
