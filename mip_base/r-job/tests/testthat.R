library(testthat)

library(hbpjdbcconnect)

df <- fetchData("select id, a, b from some_data")

saveResults(df)

print ("TODO")
