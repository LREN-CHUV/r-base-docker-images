
library(magrittr)

print("Test magrittr...");

# test that magrittr pipe operator works
stopifnot(all.equal(4 %>% sqrt(),2))

print("Success!");
