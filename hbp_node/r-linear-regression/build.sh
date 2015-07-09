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

mkdir -p downloads

cp $ROOT_DIR/../linear-regression/src/LRegress_Node.R downloads/

sudo docker build -t hbp_node/r-linear-regression .
sudo docker tag hbp_node/r-linear-regression 155.105.158.141:5000/hbp_node/r-linear-regression
sudo docker push 155.105.158.141:5000/hbp_node/r-linear-regression
