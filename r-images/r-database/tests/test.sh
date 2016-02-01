#!/bin/bash -e

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

ROOT=$(get_script_dir)/../../..

$ROOT/tests/in-db/start-db.sh

sleep 2

docker run --rm \
  --link indb:db \
  hbpmip/r-database-test test

$ROOT/tests/in-db/stop-db.sh
