[![CHUV](https://img.shields.io/badge/CHUV-LREN-AF4C64.svg)](https://www.unil.ch/lren/en/home.html)

# MIP Docker images

This project contains the Docker images used to build the core functionality of the Medical Informatics Platform (MIP).

The images are published on [Docker Hub](https://hub.docker.com/u/hbpmip/dashboard/).

The list of images and their purpose is:

## Images for the R environment

### hbpmip/r-base

Contains a standard R installation. This image is built from parent image ubuntu:17.10.

This image is similar to rocker/r-base but smaller and don't contain r-base-dev package as it brings many heavy dependencies such as gcc which are needed only when installing new packages.

### hbpmip/r-mip

Adapt the base R image to the MIP environment.

This image provides a R environment compatible with MIP. See [r-mip](mip-base/r-mip/README.md) for details.

### hbpmip/r-libs

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

### hbpmip/r-java

This image adds OpenJDK 8 and RJDBC. It is built from r-libs.

### hbpmip/r-database

This image adds database connectivity. We support RJDBC and some JDBC drivers are installed already for Postgres and Denodo, and RODBC for Postgress.

This image is built from r-java.

### hbpmip/r-job

This Docker image layer is the base for workflow jobs executing R scripts.

hbpjdbcconnect R package is installed to simplify getting data in and out of the database.

This image is built from r-database.

### hbpmip/r-interactive

This Docker image is functionally similar to r-job, but it is built on top of rocker-r-base and it is significantly bigger. It contains also some additional tools and libraries to make the development of R packages easier.

# Building

## Pre-requesites

Install [Docker engine](https://docs.docker.com/engine/installation/ubuntulinux/) and [captain](https://github.com/harbur/captain).

If you are working on the MIP, please use the [dev setup](https://github.com/LREN-CHUV/dev-setup) scripts. Run ./setup.sh, then select 3) Algorithms developer to have the necessary software installed for you.

Run ./after-git-clone.sh script after cloning this repository to fetch the code for all sub-projects.

Run ./after-update.sh after updating the code for this repository to keep the sub-projects up-to-date.

## Build scripts

./build.sh located on the root of this project will attempt to build all images expect the base images.
Use ./build.sh --all to build all images including the base images (required the first time you work on this project).

Each folder contains a build.sh script use to create the image defined in the same folder.
