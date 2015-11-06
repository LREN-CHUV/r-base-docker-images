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

IMAGES="mip_base/r-libs mip_base/r-java mip_base/r-database mip_base/r-job mip_tools/r-interactive mip_federation/workflow"

if [ "$1" = "--all" ]; then
  IMAGES="mip_base/r-base $IMAGES"
else
  echo "Skip building base images. Add --all parameter to build also those base images"
fi

for image in $IMAGES ; do
  cd $ROOT_DIR/$image
  captain test
  captain push
done
