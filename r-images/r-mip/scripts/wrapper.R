library(hbpjdbcconnect);

sink(Sys.getenv("ERROR_FILE", "/data/out/errors.txt"), type="message");
sink(Sys.getenv("OUTPUT_FILE", "/data/out/output.txt"), type="output");

tryCatch({
    source("/src/main.R");
  },
  error = function(e) {
  	saveError(error=e);
  }
);
