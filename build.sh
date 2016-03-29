#!/bin/bash -e

# Usage:
# ./build.sh [--all] [--R] [--java]

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

R_IMAGES="r-mip r-libs r-java r-database r-job r-interactive"
JAVA_IMAGES="java-base java-mip"

R_BUILD=false
JAVA_BUILD=false

NARGS=-1; while [ "$#" -ne "$NARGS" ]; do NARGS=$#
    case $1 in
        "-h"|"--help")
            echo "Ugage:"
            echo "./build.sh [--all] [--R] [--java]"
            exit 1;
            break
            ;;
        "--all")
            R_IMAGES="r-base $R_IMAGES"
            R_BUILD=true
            JAVA_BUILD=true
            break
            ;;
        "--R"|"--r")
            R_BUILD=true
            break
            ;;
        "--java")
            JAVA_BUILD=true
            break
            ;;
        "")
            if [[ $NARGS == 0 ]]; then
              R_BUILD=true
              JAVA_BUILD=true
            fi
            break
            ;;
        *) echo invalid option;;
    esac
done

if [ "$1" = "--all" ]; then
  R_IMAGES="r-base $R_IMAGES"
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

if [[ $R_BUILD == true ]]; then
  pushd $ROOT_DIR/r-images
  for image in $R_IMAGES ; do
    pushd $image
    $CAPTAIN test
    $DOCKER push hbpmip/$image:$commit_id
    $DOCKER push hbpmip/$image:latest
    popd
  done
  popd
fi

if [[ $JAVA_BUILD == true ]]; then
  pushd $ROOT_DIR/java-images
  for image in $JAVA_IMAGES ; do
    pushd $image
    $CAPTAIN test
    $DOCKER push hbpmip/$image:$commit_id
    $DOCKER push hbpmip/$image:latest
    popd
  done
  popd
fi
