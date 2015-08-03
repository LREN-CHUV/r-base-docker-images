FROM hbp/r-java:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.version=0.1 \
      eu.humanbrainproject.category=R

COPY downloads/* /usr/lib/R/libraries/

# TODO: add Denodo JDBC driver

# install packages
RUN echo 'install.packages(c("RJDBC", "RODBC", "RODBCext"), dependencies=TRUE)' > /tmp/packages.R \
    && Rscript /tmp/packages.R
