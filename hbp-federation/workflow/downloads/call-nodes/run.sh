#!/bin/sh

cd /opt/call-nodes/

request_id=$(grep -E "request_id=.*" -o run.ini | cut -d'=' -f2)
http -v DELETE 192.168.33.10::4400/scheduler/job/r-linear-regression-$request_id-CHUV
http -v DELETE 192.168.33.11::4400/scheduler/job/r-linear-regression-$request_id-Brescia

(j2 run.json.j2 run.ini > run.json && http -v --json POST 192.168.33.10:4400/scheduler/iso8601 < run.json && rm run.json) &
(j2 run.json.j2 run2.ini > run2.json && http -v --json POST 192.168.33.11:4400/scheduler/iso8601 < run2.json && rm run2.json) &
