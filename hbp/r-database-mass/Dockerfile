FROM hbp/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

RUN echo 'install.packages(c("MASS"), dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R
