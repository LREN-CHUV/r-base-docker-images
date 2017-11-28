suppressMessages(library(hbpjdbcconnect));

errFile <- file(Sys.getenv("ERROR_FILE", "/data/out/errors.txt"), open="wt");
outFile <- file(Sys.getenv("OUTPUT_FILE", "/data/out/output.txt"), open="wt");

sink(errFile, type="message");
sink(outFile, type="output");

tryCatch({
    source("/src/main.R");
  },
  error = function(e) {
  	print(e);
    saveError(error=e);
  }
);
