library(hbpjdbcconnect);

sink(Sys.getenv("ERROR_FILE", "/data/out/errors.txt"), type="message", split=T);
sink(Sys.getenv("OUTPUT_FILE", "/data/out/output.txt"), type="output", split=T);

tryCatch({
    source("/src/main.R");
  },
  error = function(e) {
  	saveError(error=e);
  }
);
