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

IMAGES="r-images/r-mip r-images/r-libs r-images/r-java r-images/r-database r-images/r-job r-images/r-interactive"

if [ "$1" = "--all" ]; then
  IMAGES="r-images/r-base $IMAGES"
else
  echo "Skip building base images. Add --all parameter to build also those base images"
fi

if groups $USER | grep &>/dev/null '\bdocker\b'; then
  CAPTAIN="captain"
  DOCKER="docker"
else
  CAPTAIN="sudo captain"
  DOCKER="sudo docker"
fi

commit_id="$(git rev-parse --short HEAD)"

for image in $IMAGES ; do
  cd $ROOT_DIR/$image
  $CAPTAIN test
  $DOCKER push $image:$commit_id
  $DOCKER push $image:latest
done
