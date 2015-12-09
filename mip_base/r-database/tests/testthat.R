library(testthat);

library(RJDBC);

drv <- JDBC("org.postgresql.Driver",
           "/usr/lib/R/libraries/postgresql-9.4-1201.jdbc41.jar",
           identifier.quote="`");
conn <- dbConnect(drv, "jdbc:postgresql://db:5432/postgres", "postgres", "test");

# Perform the computation
results <- unlist(dbGetQuery(conn, "SELECT * from some_data"));

expect_equal(results[[1]], "001");

print ("[ok] Success!");
