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

ROOT_DIR="$(get_script_dir)"/../..

mkdir -p downloads/call-nodes/

cp $ROOT_DIR/hbp-node/r-linear-regression/run* downloads/call-nodes/
cp $ROOT_DIR/../workflow/target/workflow-1.0-SNAPSHOT.jar downloads/workflow.jar

sudo docker build -t hbp-federation/workflow .
