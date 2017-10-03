#!/bin/bash -e

case "$1" in

"shell")
  /bin/bash -i
;;

"" | "R")
  /usr/bin/R
;;

"check-package")
  /usr/bin/R CMD check .
;;

"build-package")
  /usr/bin/R CMD build .
;;

"dist-package")
  /usr/bin/R CMD INSTALL --build .
;;

"help" | "-h" | "--help" | *)
  echo "Usage: ./run.sh <command>"
  echo " where command is one of"
  echo "  R: opens the R interactive shell (default)"
  echo "  shell: opens an interactive bash shell"
  echo "  check-package: check the R package located in /home/docker/data"
  echo "  build-package: build the R source package located in /home/docker/data"
  echo "  dist-package: build the R binary package located in /home/docker/data"
;;

esac
