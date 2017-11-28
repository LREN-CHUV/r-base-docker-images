library(testthat)

packages_to_test <- c(
  "jsonlite",
  "magrittr",
  "RPostgreSQL",
  "whisker",
  "yaml")

# test that packages are installed
stopifnot(packages_to_test %in% installed.packages()) 

# test that packages can be loaded (and load them)
stopifnot(all(unlist(lapply(packages_to_test, require, character.only = TRUE))))

# test each package with testthat:
test_file('testthat/testMASS.R')
test_file('testthat/testjsonlite.R')
test_file('testthat/testmagrittr.R')
test_file('testthat/testRPostgreSQL.R')
test_file('testthat/testwhisker.R')
test_file('testthat/testyaml.R')


