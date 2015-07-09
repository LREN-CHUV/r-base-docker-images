#!/bin/bash

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     $( cd -P "$( dirname "$SOURCE" )" )
     pwd
}

DIR="$(get_script_dir)"
LR_DIR=$DIR/../r-linear-regression

request_id=$(grep -E "^request_id=.*" -o run.ini | cut -d'=' -f2)
http_proxy="" http -v DELETE 127.0.0.1:4400/scheduler/job/federation-workflow-$request_id
http_proxy="" http -v DELETE 127.0.0.1:4400/scheduler/job/r-federation-linear-regression-$request_id

j2 run.json.j2 run.ini > run.json
http_proxy="" http -v --json POST 127.0.0.1:4400/scheduler/iso8601 < run.json

j2 $LR_DIR/dependent.json.j2 $LR_DIR/run.ini > dependent.json
http_proxy="" http -v --json POST 127.0.0.1:4400/scheduler/dependency < dependent.json

#rm run.json dependent.json
