#!/bin/sh -e

cd /opt/call-nodes/
./run.sh

java -cp $JDBC_JAR_PATH:/opt/workflow/workflow.jar ch.chuv.workflow.Wait
