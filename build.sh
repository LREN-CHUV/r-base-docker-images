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

ROOT_DIR="$(get_script_dir)"

for image in mip_base/r-base \
             mip_base/r-java \
             mip_base/r-database \
             mip_base/r-database-mass \
             mip_tools/r-interactive \
             mip_federation/workflow; do

	cd $ROOT_DIR/$image
	captain push
done

