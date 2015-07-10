library(rJava)
.jinit() # this starts the JVM
s <- .jnew("java/lang/String", "Hello World!")
print(s)
