library(testthat)

library(hbpjdbcconnect)

connect2indb();

print ("connected to in db")

df <- fetchData("select id, a, b from some_data")

print (df)

connect2outdb();

print ("connected to out db")

saveResults(df)

print ("TODO")
