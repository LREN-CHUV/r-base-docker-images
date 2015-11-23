#!/bin/bash -e

./tests/in-db/start-db.sh
./tests/out-db/start-db.sh

sleep 2

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  DOCKER="docker"
else
  DOCKER="sudo docker"
fi

$DOCKER run -i -t --rm \
  --link indb:indb \
  --link analyticsdb:outdb \
  -e IN_JDBC_DRIVER=org.postgresql.Driver \
  -e IN_JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar \
  -e IN_JDBC_URL="jdbc:postgresql://indb:5432/postgres" \
  -e IN_JDBC_USER=postgres \
  -e IN_JDBC_PASSWORD=test \
  -e OUT_JDBC_DRIVER=org.postgresql.Driver \
  -e OUT_JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar \
  -e OUT_JDBC_URL="jdbc:postgresql://outdb:5432/postgres" \
  -e OUT_JDBC_USER=postgres \
  -e OUT_JDBC_PASSWORD=test \
  registry.federation.mip.hbp/mip_base/r-job shell

./tests/in-db/stop-db.sh
./tests/out-db/stop-db.sh
