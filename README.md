
# MIP Docker images

This project contains the Docker images used to build the core functionality of the Medical Informatics Platform (MIP).

The list of images and their purpose is:

## mip-base

### r-base

Contains a standard R installation. This image is built from parent image debian:testing.

This image is similar to rocker/r-base but smaller and don't contain r-base-dev package as it brings many heavy dependencies such as gcc which are needed only when installing new packages.

Instead, the scripts install.r, install2.r, installGithub.r have been modified to install on-demand r-base-dev during the installation of a new package.

### r-libs

Contains some standard / usual R packages used in the MIP: 

* plyr
* jsonlite
* rjson
* rjstat

Other libraries are already present from r-base such as:

* MASS
* Matrix
* cluster
* foreign
* rpart

This image is built from r-base.

### r-java

This image adds OpenJDK 8 and RJDBC. It is built from r-libs.

### r-database

This image adds database connectivity. We support RJDBC and some JDBC drivers are installed already for Postgres and Denodo, and RODBC for Postgress.

This image is built from r-java.

### r-job

This Docker image layer is the base for workflow jobs executing R scripts.

hbpjdbcconnect R package is installed to simplify getting data in and out of the database.

This image is built from r-database.

## mip-tools

### r-interactive
