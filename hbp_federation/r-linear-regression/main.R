#
# This script computes the linear regression.
# The data (input parameters: y, A) are obtained from the local databases using a specific query.
# These queries will be the same for all nodes.
# 
# Environment variables:
# 
# - Execution context:
#      REQUEST_ID : ID of the incoming request
#      JDBC_DRIVER : class name of the JDBC driver
#      JDBC_JAR_PATH : path to the JDBC driver jar
#      JDBC_URL : JDBC connection URL
#      JDBC_USER : User for the database connection
#      JDBC_PASSWORD : Password for the database connection
#      INPUT_TABLE: name of the input table, defaults to 'results_linear_regression'
#      INPUT_RESULT_COLUMNS: list of result columns in the input table, defaults to "result_betai, result_sigmai"
#      RESULT_TABLE: name of the result table, defaults to 'federation_results_linear_regression'
#      RESULT_COLUMNS: list of columns for the result table, default to "request_id, param_beta, param_sigma, result_betaf, result_sigmaf"
#

library(MASS)
library(RJDBC)

# Initialisation
source("/src/LRegress_Federation.R")
drv <- JDBC(Sys.getenv("JDBC_DRIVER"),
           Sys.getenv("JDBC_JAR_PATH"),
           identifier.quote="`")
conn <- dbConnect(drv, Sys.getenv("JDBC_URL"), Sys.getenv("JDBC_USER"), Sys.getenv("JDBC_PASSWORD"))
request_id <- Sys.getenv("REQUEST_ID")
input_table <- Sys.getenv("INPUT_TABLE", "results_linear_regression")
input_result_columns <- Sys.getenv("INPUT_RESULT_COLUMNS", "result_betai, result_sigmai")

# Perform the computation
results <- unlist(dbGetQuery(conn, paste("select ", input_result_columns, "from ", input_table, " where request_id = ?"), request_id))
names(results) <- c('beta1','beta2','Sigma1','Sigma2')

res <- do.call(LRegress_Federation, as.list(results))
n <- length(results)

betas <- results[seq(1, n / 2)]
sigmas <- results[seq(n / 2 + 1, n)]

betas_arr <- paste('{', paste(betas, collapse=','), '}', sep='')
sigmas_arr <- paste('{', paste(sigmas, collapse=','), '}', sep='')

result_table <- Sys.getenv("RESULT_TABLE", "federation_results_linear_regression")
result_columns <- Sys.getenv("RESULT_COLUMNS", "request_id, param_beta, param_sigma, result_betaf, result_sigmaf")

# Store results in the database
dbSendUpdate(conn, paste( "INSERT INTO ", result_table, "(", result_columns, ") VALUES (?, ?, ?, ?, ?)"),
	request_id, betas_arr, sigmas_arr, res[[1]], res[[2]])

# Disconnect from the database server
dbDisconnect(conn)
