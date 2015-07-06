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

cp $ROOT_DIR/../linear-regression/src/LRegress_Federation.R downloads/

sudo docker build -t hbp-federation/r-linear-regression .
