#/bin/bash

get_script_dir () {
     SOURCE="${BASH_SOURCE[0]}"

     while [ -h "$SOURCE" ]; do
          DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
          SOURCE="$( readlink "$SOURCE" )"
          [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
     done
     cd -P "$( dirname "$SOURCE" )"
     pwd
}

cd $(get_script_dir)

mkdir -p downloads

cd downloads

for pkg in postgresql-9.3-1103.jdbc41.jar postgresql-9.4-1201.jdbc41.jar ; do
	[ -f $pkg ] || curl -O https://jdbc.postgresql.org/download/$pkg
done

[ -f denodo-vdp-jdbcdriver.jar ] || curl -u guest:guest -O http://hbps1.chuv.ch/community/share/_IT-tools/federation/drivers/vdp-jdbcdriver-core/denodo-vdp-jdbcdriver.jar

cd ..
