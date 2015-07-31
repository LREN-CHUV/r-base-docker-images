
# Base image for R scripts

This base image provides a R environment with the following properties:

* The *computation* user is used to run the R scripts
* Directories /var/run/compute/in and /var/run/compute/out are intended to store the incoming files
  and outgoing files for the computations. They can be mounted on an external filesystem.
* The environment variables COMPUTE_IN and COMPUTE_OUT can be used to locate those folders from the R scripts.
* In the /src directory you should place all scripts and libraries used to perform the computation.
* If you run the container with the *export* command and mount /var/run/compute/out to a local directory,
  the source files will be copied to that local directory.
* If you run the container with the *serve* command, a web server will run and display any content located in /var/www/html/.
  You should place in this folder the documentation for the container.
* If you run the container with the *export-docs* command and mount /var/run/compute/out to a local directory,
  the documentation will be copied to that local directory.
