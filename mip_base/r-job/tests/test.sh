#!/bin/sh

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

DIR=$(get_script_dir)
ROOT=$DIR/../../..

$ROOT/tests/in-db/start-db.sh
$DIR/out-db/start-db.sh

docker run --rm \
  --link indb:indb \
  --link analyticsdb:outdb \
  -e JOB_ID=001 \
  -e NODE=job_test \
  -e IN_JDBC_DRIVER=org.postgresql.Driver \
  -e IN_JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar \
  -e IN_JDBC_URL=jdbc:postgresql://indb:5432/postgres \
  -e IN_JDBC_USER=postgres \
  -e IN_JDBC_PASSWORD=test \
  -e OUT_JDBC_DRIVER=org.postgresql.Driver \
  -e OUT_JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar \
  -e OUT_JDBC_URL=jdbc:postgresql://outdb:5432/postgres \
  -e OUT_JDBC_USER=postgres \
  -e OUT_JDBC_PASSWORD=test \
  registry.federation.mip.hbp/mip_base/r-job-test test

$ROOT/tests/in-db/stop-db.sh
$DIR/out-db/stop-db.sh
