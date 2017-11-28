library(RPostgreSQL)

print("Test RPostgreSQL...");

# create a connection save the password that we can 'hide' it as best as we can
# by collapsing it
pw <- {
    "data"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL");

# creates a connection to the Postgres database note that 'con' will be used
# later in each connection to the database
con <- dbConnect(drv, dbname = "data", host = "db", port = 5432, user = "data", password = pw);
rm(pw);  # removes the password

# check for the cartable
dbExistsTable(con, "sample_data");

print("Success!");
