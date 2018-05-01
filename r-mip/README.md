[![DockerHub](https://img.shields.io/badge/docker-hbpmip%r--mip-008bb8.svg)](https://hub.docker.com/r/hbpmip/r-mip/) [![ImageVersion](https://images.microbadger.com/badges/version/hbpmip/r-mip.svg)](https://hub.docker.com/r/hbpmip/r-mip/tags "hbpmip/r-mip image tags") [![ImageLayers](https://images.microbadger.com/badges/image/hbpmip/r-mip.svg)](https://microbadger.com/#/images/hbpmip/r-mip "hbpmip/r-mip on microbadger")

# Adapt the base R image to the MIP environment

This image provides a R environment compatible with MIP and providing the following features:

* The *compute* user is used to run the R scripts
* Directories /data/in and /data/out are intended to store the incoming files
  and outgoing files for the computations. They can be mounted on an external filesystem.
* The environment variables COMPUTE_IN and COMPUTE_OUT can be used to locate those folders from the R scripts.
* In the /src directory you should place all scripts and libraries used to perform the computation.
* If you run the container with the *export* command and mount /data/out to a local directory,
  the source files will be copied to that local directory.
* If you run the container with the *serve* command, a web server will run and display any content located in /var/www/html/.
  You should place in this folder the documentation for the container.
* If you run the container with the *export-docs* command and mount /data/out to a local directory,
  the documentation will be copied to that local directory.
* If you run the container with the *shell* command, an interactive shell will start.
* testthat package is installed to encourage writting unit tests.

## Usage

Use this image as the parent image to adapt a R algorithm to the MIP platform:

Dockerfile
```dockerfile
  FROM hbpmip/r-base-build:3.4.2-2 as r-build-env

  RUN install.r my_lib

  FROM hbpmip/r-mip:0.5.1

  COPY --from=r-build-env /usr/local/lib/R/site-libraries/my_lib/ /usr/local/lib/R/site-libraries/my_lib/

  MAINTAINER <your email>

  ENV DOCKER_IMAGE=hbpmip/my-algo:1.0.0 \
      FUNCTION=my-algo

  COPY --from=r-build-env /usr/local/lib/R/site-library/my_algo/ /usr/local/lib/R/site-library/my_algo/
  COPY main.R /src/
  COPY tests/testthat.R /src/tests/
  COPY tests/testthat/ /src/tests/testthat/

  RUN chown -R compute:compute /src/ \
      && chown -R root:www-data /var/www/html/
```

## Summary of commands:

* Run the main computations

  ```sh
    mkdir -p in out && docker run --rm -v $(pwd)/in:/data/in -v $(pwd)/out:/data/out <image name> compute
  ````

* Export the documentation to the ./doc directory

  ```sh
    docker run --rm -v /data/out:./doc <image name> export-docs
  ```

* Interactive shell

  ```sh
    docker run -i -t --rm <image name> shell
  ```

* Quick documentation accessible at http://localhost:7777/ and sources at http://localhost:7777/src/
  Stop the server using Ctrl+C from the command line.

  ```sh
    docker run -i -t --rm -p 7777:80 <image name> serve
  ```

* Export the sources to the ./src directory

  ```sh
    mkdir -p src && docker run --rm -v $(pwd)/src:/data/out <image name> export
  ```

* Export the documentation to the ./doc directory

  ```sh
    mkdir -p doc && docker run --rm -v $(pwd)/doc:/data/out <image name> export-docs
  ```

## Useful environment variables:

* COMPUTE_IN: the directory containing the input files
* COMPUTE_OUT: the output directory to use to store the output files
* COMPUTE_TMP: the directory to use to store temporary files
* SRC: the directory containing the sources
