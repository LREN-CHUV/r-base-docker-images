FROM registry.federation.mip.hbp/hbp/r-database:latest

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.function=linear-regression \
      eu.humanbrainproject.function.location=federation \
      eu.humanbrainproject.function.version=0.1 \
      eu.humanbrainproject.function.author="Ludovic Claude" \
      eu.humanbrainproject.function.organisation="LREN, CHUV" \
      eu.humanbrainproject.function.date="2015-07-06"

RUN echo "deb http://http.debian.net/debian jessie main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y curl python-pip && \
    pip install j2cli

COPY downloads/call-nodes/ /opt/call-nodes/
COPY downloads/workflow.jar /opt/workflow/
COPY downloads/workflow.sh /opt/workflow/

RUN chmod +x /opt/call-nodes/run.sh /opt/workflow/workflow.sh && \
    ln -s /opt/workflow/workflow.sh /run.sh

CMD /opt/workflow/workflow.sh
