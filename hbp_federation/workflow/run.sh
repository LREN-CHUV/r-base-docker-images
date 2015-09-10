#!/bin/bash -e

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
CHRONOS_FEDERATION=lab01560.intranet.chuv:4400

request_id=$(grep -E "^request_id=.*" -o run.ini | cut -d'=' -f2)
http_proxy="" \
  curl -v \
    -XDELETE \
    $CHRONOS_FEDERATION/scheduler/job/federation-workflow-$request_id
http_proxy="" \
  curl -v \
    -XDELETE \
    $CHRONOS_FEDERATION/scheduler/job/r-federation-linear-regression-$request_id

lsof -i :14400 > /dev/null || ssh -f ludovic@hbps2.intranet.chuv -L 0.0.0.0:14400:hbps2.intranet.chuv:4400 -N
lsof -i :24400 > /dev/null || ssh -f ludovic@hbps3.intranet.chuv -L 0.0.0.0:24400:hbps3.intranet.chuv:4400 -N

# ensure that the latest workflow image is used
docker pull registry.federation.mip.hbp/hbp_federation/workflow:latest
docker pull registry.federation.mip.hbp/hbp_federation/r-linear-regression:latest

j2 run.json.j2 run.ini > run.json
http_proxy="" \
  curl -v \
    -XPOST \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    --data-binary @run.json \
    $CHRONOS_FEDERATION/scheduler/iso8601

j2 $LR_DIR/dependent.json.j2 dependent.ini > dependent.json
http_proxy="" \
  curl -v \
    -XPOST \
    -H "Accept: application/json" \
    -H "Content-type: application/json" \
    --data-binary @dependent.json \
    $CHRONOS_FEDERATION/scheduler/dependency

#rm run.json dependent.json
