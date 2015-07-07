FROM java:openjdk-8u45-jre

MAINTAINER ludovic.claude54@gmail.com

LABEL eu.humanbrainproject.function=linear-regression \
      eu.humanbrainproject.function.location=federation \
      eu.humanbrainproject.function.version=0.1 \
      eu.humanbrainproject.function.author="Ludovic Claude" \
      eu.humanbrainproject.function.organisation="LREN, CHUV" \
      eu.humanbrainproject.function.date="2015-07-06"

COPY downloads/call-nodes/ /opt/call-nodes/
COPY downloads/workflow.jar /opt/workflow/

RUN echo "Acquire::http::Proxy \"http://PROXY:8080/\";" > /etc/apt/apt.conf && \
    echo "deb http://http.debian.net/debian jessie main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y httpie && \
    echo "#!/bin/sh\n/opt/call-nodes/run.sh\njava -jar /opt/workflow/workflow.jar" > /run.sh && \
    chmod +x /run.sh /opt/call-nodes/run.sh

CMD /run.sh
