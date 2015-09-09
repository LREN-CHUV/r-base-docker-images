#!/bin/sh -e

cd /opt/call-nodes/
./run.sh

java -cp $JDBC_JAR_PATH -jar /opt/workflow/workflow.jar
