
# This script computes the linear regression.
# The data (input parameters: y, A) are obtained from the local databases using a specific query.
# These queries will be the same for all nodes.
# 
# Environment variables:
# 
# - Input Parameters:
#      PARAM_y  : SQL query producing the y parameter of L_Regress_Node
#      PARAM_A : SQL query producing the A parameter of L_Regress_Node
# - Execution context:
#      REQUEST_ID : ID of the incoming request
#      JDBC_DRIVER : class name of the JDBC driver
#      JDBC_JAR_PATH : path to the JDBC driver jar
#      JDBC_URL : JDBC connection URL
#      JDBC_USER : User for the database connection
#      JDBC_PASSWORD : Password for the database connection
# --------------------------------------------------------------------------#

library(MASS)
library(RJDBC)

# Initialisation
source("/usr/local/share/R/scripts/LRegress_Node.R")
drv <- JDBC(Sys.getenv("JDBC_DRIVER"),
           Sys.getenv("JDBC_JAR_PATH"),
           identifier.quote="`")
conn <- dbConnect(drv, Sys.getenv("JDBC_URL"), Sys.getenv("JDBC_USER"), Sys.getenv("JDBC_PASSWORD"))
request_id <- Sys.getenv("REQUEST_ID")
yQuery <- Sys.getenv("PARAM_y")
A_Query <- Sys.getenv("PARAM_A")

# Perform the computation
y <- unlist(dbGetQuery(conn, yQuery))
A <- unlist(dbGetQuery(conn, A_Query))
res <- LRegress_Node(y, A)

# Store results in the database
dbSendUpdate(conn, "INSERT INTO results_linear_regression(request_id, param_y, param_a, result_betai, result_sigmai) VALUES (?, ?, ?, ?, ?)",
	request_id, yQuery, A_Query, res[[1]], res[[2]])

# Disconnect from the database server
dbDisconnect(conn)
