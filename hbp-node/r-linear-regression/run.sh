#!/bin/sh

http -v DELETE localhost:4400/scheduler/job/r-linerar-regression-002

j2 run.json.j2 run.ini > run.json
http -v --json POST localhost:4400/scheduler/iso8601 < run.json

rm run.json
