#!/bin/sh

cd /opt/call-nodes/

#NODE1=hbps2.chuv.ch:4400
#NODE2=hbps3.chuv.ch:4400

(
	export URL=155.105.202.126:14400
	export NODE=CHUV
    export IN_JDBC_URL=jdbc:postgresql://hbps2.intranet.chuv:5432/LDSM1
    export OUT_JDBC_URL=jdbc:postgresql://hbps2.intranet.chuv:31432/analytics

	http -v DELETE $URL/scheduler/job/r-linear-regression-$REQUEST_ID-$NODE
    j2 -f env run.ini.j2 > run1.ini
    j2 run.json.j2 run1.ini > run1.json
    http_proxy="" http -v --json POST $URL/scheduler/iso8601 @run1.json
) &

(
	export URL=155.105.202.126:24400
	export NODE=CHUV-ADNI
    export IN_JDBC_URL=jdbc:postgresql://hbps3.intranet.chuv:5432/LDSM3
    export OUT_JDBC_URL=jdbc:postgresql://hbps3.intranet.chuv:31432/analytics
    
    http -v DELETE $URL/scheduler/job/r-linear-regression-$REQUEST_ID-$NODE
    j2 -f env run.ini.j2 > run2.ini
    j2 run.json.j2 run2.ini > run2.json
    http_proxy="" http -v --json POST $URL/scheduler/iso8601 @run2.json
) &
