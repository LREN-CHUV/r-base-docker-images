#!/bin/sh

cd /opt/call-nodes/

request_id=$(grep -E "request_id=.*" -o run.ini | cut -d'=' -f2)
http -v DELETE hbps2.chuv.ch:4400/scheduler/job/r-linear-regression-$request_id-CHUV
http -v DELETE hbps3.chuv.ch:4400/scheduler/job/r-linear-regression-$request_id-Brescia

(j2 run.json.j2 run.ini > run.json && http_proxy="" http -v --json POST hbps2.chuv.ch:4400/scheduler/iso8601 < run.json && rm run.json) &
(j2 run.json.j2 run2.ini > run2.json && http_proxy="" http -v --json POST hbps3.chuv.ch:4400/scheduler/iso8601 < run2.json && rm run2.json) &
