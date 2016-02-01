
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

## Summary of commands:

* Run the main computations
  ````
    mkdir doc && docker run --rm -v $(pwd)/in:/data/in -v $(pwd)/out:/data/out <image name> compute
  ````
* Export the documentation to the ./doc directory
  ````
    docker run --rm -v /data/out:./doc <image name> export-docs
  ````
* Interactive shell
  ````
    docker run -i -t --rm <image name> shell
  ````
* Quick documentation accessible at http://localhost:7777/ and sources at http://localhost:7777/src/
  Stop the server using Ctrl+C from the command line.
  ````
    docker run -i -t --rm -p 7777:80 <image name> serve
  ````
* Export the sources to the ./src directory
  ````
    mkdir src && docker run --rm -v $(pwd)/src:/data/out <image name> export
  ````
* Export the documentation to the ./doc directory
  ````
    mkdir doc && docker run --rm -v $(pwd)/doc:/data/out <image name> export-docs
  ````
