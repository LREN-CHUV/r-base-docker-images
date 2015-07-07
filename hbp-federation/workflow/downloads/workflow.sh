#!/bin/sh

cd /opt/call-nodes/
./run.sh 192.168.33.10:4400 run.ini &
./run.sh 192.168.33.11:4400 run2.ini &

java -jar /opt/workflow/workflow.jar
