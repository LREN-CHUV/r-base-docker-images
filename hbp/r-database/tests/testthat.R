library(testthat)

library(RJDBC)

drv <- JDBC("org.postgresql.Driver",
           "/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar",
           identifier.quote="`")
conn <- dbConnect(drv, "jdbc:postgresql://postgres:5432/postgres", "postgres", "test")

# Perform the computation
results <- unlist(dbGetQuery(conn, "SELECT * from test.test"))

expect_equal(results[[1]], "It works!")
