#!/bin/bash -e

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"
     while [ -h "$SOURCE" ]; do
     echo "Go up"
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     ( cd -P "$( dirname "$SOURCE" )" ; pwd)
}

ROOT_DIR="$(get_script_dir)"

for image in hbp/r-base \
             hbp/r-java \
             hbp/r-database \
             hbp/r-database-mass \
             hbp_node/r-linear-regression \
             hbp_federation/r-linear-regression ; do

   	# TODO: hbp_federation/workflow
   	# TODO: hbp_desktop/*

	cd $ROOT_DIR/$image
	captain push
done

