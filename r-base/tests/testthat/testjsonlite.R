library(jsonlite)

print("Test jsonlite...")

# test that json stringification and parsing back works
jsoncars <- toJSON(mtcars, pretty=TRUE)
mtcars_new <-  fromJSON(jsoncars)
expect_equal(mtcars,mtcars_new)

print("Success!")
