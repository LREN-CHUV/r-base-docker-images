#!/bin/bash

mkdir -p downloads

cd downloads

for pkg in DBI_0.3.1.tar.gz rJava_0.9-6.tar.gz RJDBC_0.2-5.tar.gz ; do
	[ -f $pkg ] || curl -O http://cran.r-project.org/src/contrib/$pkg
done

cd ..

sudo docker build -t hbp/r-jdbc .
