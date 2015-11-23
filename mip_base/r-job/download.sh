#!/bin/sh
CONNECT_DIR="../../../../mip-functions/hbpjdbcconnect"

(cd $CONNECT_DIR && ./build.sh && ./dist.sh)
cp $CONNECT_DIR/hbpjdbcconnect_0.0.0.9000_R_x86_64-pc-linux-gnu.tar.gz downloads/
