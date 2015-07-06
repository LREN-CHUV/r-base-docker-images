
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
# --------------------------------------------------------------------------#

library(MASS)
library(RJDBC)

# Initialisation
source("/usr/local/share/R/scripts/LRegress_Federation.R")
drv <- JDBC(Sys.getenv("JDBC_DRIVER"),
           Sys.getenv("JDBC_JAR_PATH"),
           identifier.quote="`")
conn <- dbConnect(drv, Sys.getenv("JDBC_URL"), Sys.getenv("JDBC_USER"), Sys.getenv("JDBC_PASSWORD"))
request_id <- Sys.getenv("REQUEST_ID")

# Perform the computation
results <- unlist(dbGetQuery(conn, "select result_betai, result_sigmai from results_linear_regression where request_id = ?", request_id))
names(results) <- c('beta1','beta2','Sigma1','Sigma2')

res <- do.call(LRegress_Federation, as.list(results))

betas <- results[seq(1, length(results) / 2)]
sigmas <- results[seq(length(results) / 2 + 1, length(results))]

betas_arr <- paste('{', paste(betas, collapse=','), '}', sep='')
sigmas_arr <- paste('{', paste(sigmas, collapse=','), '}', sep='')

# Store results in the database
dbSendUpdate(conn, "INSERT INTO federation_results_linear_regression(request_id, param_beta, param_sigma, result_betaf, result_sigmaf) VALUES (?, ?, ?, ?, ?)",
	request_id, betas_arr, sigmas_arr, res[[1]], res[[2]])

# Disconnect from the database server
dbDisconnect(conn)
