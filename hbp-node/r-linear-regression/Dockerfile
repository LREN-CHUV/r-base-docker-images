FROM hbp/r-jdbc-mass:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.function=linear-regression \
      eu.humanbrainproject.function.version=0.1" \
      eu.humanbrainproject.function.author="Lester Melie-Garcia" \
      eu.humanbrainproject.function.organisation="LREN, CHUV" \
      eu.humanbrainproject.function.date="2015-06-27"

COPY downloads/LRegress_Node.R /usr/local/share/R/scripts/
COPY main.R /usr/local/share/R/scripts/

CMD ["/usr/bin/R", "BATCH", "-f", "/usr/local/share/R/scripts/main.R"]
