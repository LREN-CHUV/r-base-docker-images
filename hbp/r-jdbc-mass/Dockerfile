FROM hbp/r-jdbc:latest

MAINTAINER ludovic.claude54@gmail.com

COPY downloads/* /usr/lib/R/libraries/

RUN R CMD INSTALL /usr/lib/R/libraries/MASS_7.3-42.tar.gz
