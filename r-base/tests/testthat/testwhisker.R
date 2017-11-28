library(whisker)

print("Test whisker...");

# test basic whisker
template <- "Hello {{place}}!"
place <- "World"
stopifnot(all.equal(whisker.render(template),"Hello World!"))

print("Success!");
