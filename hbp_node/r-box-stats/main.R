#
# XXX This script computes the linear regression.
# XXX The data (input parameters: y, A) are obtained from the local databases using a specific query.
# XXX These queries will be the same for all nodes.
# 
# Environment variables:
# 
# - Input Parameters:
#      PARAM_query  : SQL query producing the dataframe to analyse
# - Execution context:
#      REQUEST_ID : ID of the incoming request
#      NODE : Node used for the execution of the script
#      IN_JDBC_DRIVER : class name of the JDBC driver for input data
#      IN_JDBC_JAR_PATH : path to the JDBC driver jar for input data
#      IN_JDBC_URL : JDBC connection URL for input data
#      IN_JDBC_USER : User for the database connection for input data
#      IN_JDBC_PASSWORD : Password for the database connection for input data
#      OUT_JDBC_DRIVER : class name of the JDBC driver for output results
#      OUT_JDBC_JAR_PATH : path to the JDBC driver jar for output results
#      OUT_JDBC_URL : JDBC connection URL for output results
#      OUT_JDBC_USER : User for the database connection for output results
#      OUT_JDBC_PASSWORD : Password for the database connection for output results
#      RESULT_TABLE: name of the result table, defaults to 'results_linear_regression'
#

library(hbpboxstats)
library(RJDBC)

# Initialisation
drv <- JDBC(Sys.getenv("IN_JDBC_DRIVER"),
           Sys.getenv("IN_JDBC_JAR_PATH"),
           identifier.quote="`")
conn <- dbConnect(drv, Sys.getenv("IN_JDBC_URL"), Sys.getenv("IN_JDBC_USER"), Sys.getenv("IN_JDBC_PASSWORD"))
request_id <- Sys.getenv("REQUEST_ID")
node <- Sys.getenv("NODE")
query <- Sys.getenv("PARAM_query")
in_schema <- Sys.getenv("IN_SCHEMA", "")

if (in_schema != "") {
  dbSendUpdate(conn, paste("SET search_path TO '", in_schema, "'", sep=""))
}

# Perform the computation
y <- unlist(dbGetQuery(conn, query))

res <- BoxStats_Node(y)

result_table <- Sys.getenv("RESULT_TABLE", "results_box_stats")

if (Sys.getenv("IN_JDBC_DRIVER") != Sys.getenv("OUT_JDBC_DRIVER") ||
	Sys.getenv("IN_JDBC_JAR_PATH") != Sys.getenv("OUT_JDBC_JAR_PATH")) {

	outDrv <- JDBC(Sys.getenv("OUTJDBC_DRIVER"),
           Sys.getenv("OUT_JDBC_JAR_PATH"),
           identifier.quote="`")
} else {
	outDrv <- drv
}

if (Sys.getenv("IN_JDBC_URL") != Sys.getenv("OUT_JDBC_URL") ||
	Sys.getenv("IN_JDBC_USER") != Sys.getenv("OUT_JDBC_USER") ||
	Sys.getenv("IN_JDBC_PASSWORD") != Sys.getenv("OUT_JDBC_PASSWORD")) {

    outConn <- dbConnect(drv, Sys.getenv("OUT_JDBC_URL"), Sys.getenv("OUT_JDBC_USER"), Sys.getenv("OUT_JDBC_PASSWORD"))
} else {
	outConn <- conn
}

out_schema <- Sys.getenv("OUT_SCHEMA", "")

if (out_schema != "") {
  dbSendUpdate(conn, paste("SET search_path TO '", out_schema, "'", sep=""))
}

# Store results in the database
n <- 1
results <- data.frame(request_id = rep(request_id, n), node = rep(node, n), id = 1:n,
	               min = res['min'], q1 = res['q1'], median = res['median'], q3 = res['q3'], max = res['max'])

dbWriteTable(conn, result_table, results, overwrite=FALSE, append=TRUE, row.names = FALSE)

# Disconnect from the database server
if (Sys.getenv("IN_JDBC_URL") != Sys.getenv("OUT_JDBC_URL")) dbDisconnect(outConn)
dbDisconnect(conn)
