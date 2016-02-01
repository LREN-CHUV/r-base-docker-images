library(testthat)
library(rJava)

.jinit() # this starts the JVM
s <- .jnew("java/lang/String", "Hello World!")

expect_equal(.jclass(s), "java.lang.String")
expect_equal(.jsimplify(s), "Hello World!")

print ("Success!")
