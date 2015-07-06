#!/bin/sh
docker run -i -t --rm \
  -e REQUEST_ID=001 \
  -e PARAM_y="select tissue1_volume from brain_feature where feature_name='Hippocampus_L'" \
  -e PARAM_A="select tissue1_volume from brain_feature where feature_name='Hippocampus_R'" \
  -e JDBC_DRIVER=org.postgresql.Driver \
  -e JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar \
  -e JDBC_URL=jdbc:postgresql://155.105.158.141:5432/CHUV_MIPS \
  -e JDBC_USER=postgres \
  -e JDBC_PASSWORD=Mordor1975 \
  -v /home/ludovic/tmp:/log \
  hbp-node/r-linear-regression