FROM cardcorp/r-java:latest

MAINTAINER ludovic.claude54@gmail.com
LABEL eu.humanbrainproject.version=0.1
COPY downloads/* /usr/lib/R/libraries/

RUN R CMD INSTALL /usr/lib/R/libraries/DBI_0.3.1.tar.gz /usr/lib/R/libraries/rJava_0.9-6.tar.gz /usr/lib/R/libraries/RJDBC_0.2-5.tar.gz
