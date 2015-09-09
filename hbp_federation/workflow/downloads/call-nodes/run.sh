#!/bin/sh

cd /opt/call-nodes/

#NODE1=hbps2.chuv.ch:4400
#NODE2=hbps3.chuv.ch:4400

NODE1=155.105.202.126:14400
NODE2=155.105.202.126:24400

http -v DELETE $NODE1/scheduler/job/r-linear-regression-$REQUEST_ID-CHUV
http -v DELETE $NODE2/scheduler/job/r-linear-regression-$REQUEST_ID-Brescia

(
	NODE=CHUV \
      IN_JDBC_URL=jdbc:postgresql://hbps2.intranet.chuv:5432/LDSM1 \
      OUT_JDBC_URL=jdbc:postgresql://hbps2.intranet.chuv:31432/analytics \
      j2 -f env run.ini.j2 > run1.ini
    j2 run.json.j2 run1.ini > run1.json
    http_proxy="" http -v --json POST $NODE1/scheduler/iso8601 < run1.json
    rm run1.json
) &

(
	NODE=CHUV-ADNI \
      IN_JDBC_URL=jdbc:postgresql://hbps3.intranet.chuv:5432/LDSM3 \
      OUT_JDBC_URL=jdbc:postgresql://hbps3.intranet.chuv:31432/analytics \
      j2 -f env run.ini.j2 > run2.ini
    j2 run.json.j2 run2.ini > run2.json
    http_proxy="" http -v --json POST $NODE1/scheduler/iso8601 < run2.json
    rm run2.json
) &
