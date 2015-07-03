library(MASS)
source("/usr/local/share/R/scripts/LRegress_Node.R")

library(RJDBC)
drv <- JDBC("org.postgresql.Driver",
           "/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar",
           identifier.quote="`")
conn <- dbConnect(drv, "jdbc:postgresql://155.105.158.141:5432/CHUV_MIPS", "postgres", "Mordor1975")

var01<-unlist(dbGetQuery(conn, "select tissue1_volume from brain_feature where feature_name='Hippocampus_L'"))
var02<-unlist(dbGetQuery(conn, "select tissue1_volume from brain_feature where feature_name='Hippocampus_R'"))

f1<-summary(lm(var01~var02))
f1
w1<-1/f1$coefficients["var02","Std. Error"]
w1
b1<-f1$coefficients["var02","Estimate"]
b1

#JDBC_DRIVER=org.postgresql.Driver
#JDBC_JAR_PATH=/usr/lib/R/libraries/postgresql-9.3-1103.jdbc41.jar
#JDBC_URL=jdbc:postgresql://155.105.158.141:5432/CHUV_MIPS
#JDBC_USER=postgres
#JDBC_PASSWORD=Mordor1975
