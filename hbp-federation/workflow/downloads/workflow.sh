#!/bin/sh

/opt/call-nodes/run.sh 192.168.33.10:4400 /opt/call-nodes/run.ini &
/opt/call-nodes/run.sh 192.168.33.11:4400 /opt/call-nodes/run2.ini &
java -jar /opt/workflow/workflow.jar
