library(testthat);
library(hbpjdbcconnect);

connect2indb();

print ("[ok] Connected to in db");

df <- fetchData("select id, a, b from some_data");

expect_equal(nrow(df), 2);

Sys.sleep(1);

connect2outdb();

print ("[ok] Connected to out db");

saveResults(df);

library(RJDBC);
connect2outdb();
res <- RJDBC::dbGetQuery(out_conn, "select * from job_result");
disconnectdbs();

expect_equal(res[1,'job_id'], '001');
expect_equal(res[1,'node'],   'job_test');
expect_equal(res[1,'data'],   '[{"id":"001","a":1,"b":2},{"id":"002","a":2,"b":3}]');

print ("[ok] Test passed");
