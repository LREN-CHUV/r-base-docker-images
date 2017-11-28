library(testthat)

a <- 9
expect_that(a, is_less_than(10))
expect_lt(a, 10)

print ("Success!")
