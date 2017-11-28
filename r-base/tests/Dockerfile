FROM hbpmip/r-base:latest

MAINTAINER ludovic.claude54@gmail.com

COPY testthat.R /src/tests/
COPY testthat/ /src/tests/testthat/

WORKDIR /src/tests

ENTRYPOINT ["/usr/bin/Rscript", "/src/tests/testthat.R"]
