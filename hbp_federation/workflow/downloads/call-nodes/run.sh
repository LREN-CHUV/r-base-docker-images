#!/bin/sh

cd /opt/call-nodes/

#NODE1=hbps2.chuv.ch:4400
#NODE2=hbps3.chuv.ch:4400

NODE1=155.105.202.126:14400
NODE2=155.105.202.126:24400

request_id=$(grep -E "request_id=.*" -o run.ini | cut -d'=' -f2)
http -v DELETE $NODE1/scheduler/job/r-linear-regression-$request_id-CHUV
http -v DELETE $NODE2/scheduler/job/r-linear-regression-$request_id-Brescia

(j2 run.json.j2 run.ini > run.json && http_proxy="" http -v --json POST $NODE1/scheduler/iso8601 < run.json && rm run.json) &
(j2 run.json.j2 run2.ini > run2.json && http_proxy="" http -v --json POST $NODE2/scheduler/iso8601 < run2.json && rm run2.json) &
