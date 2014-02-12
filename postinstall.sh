#!/bin/bash

ZOOKEEPER_VERSION=3.4.5

create_dir(){
  PATH_TO_FILE=$1
  [ -d $PATH_TO_FILE ] || mkdir $PATH_TO_FILE
}

download() {
  URI=$1
  [ -f  $(basename $URI) ] || wget $URI
}

uncompress() {
  FILE_NAME=$1
  [ -d ${FILE_NAME%*.tar.gz} ] || tar -xzf $FILE_NAME
}

append_to_file() {
  LINE=$1
  PATH_TO_FILE=$2

  [ -f $PATH_TO_FILE ] || touch  $PATH_TO_FILE
  grep -q "${LINE}" ${PATH_TO_FILE} || echo ${LINE} >> ${PATH_TO_FILE}
}



sudo aptitude install -y  build-essential gcc g++ uuid-dev libtool git pkg-config autoconf

create_dir tools
pushd tools

### ZooKeeper ###
download "http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz"
uncompress "zookeeper-${ZOOKEEPER_VERSION}.tar.gz"

pushd "zookeeper-${ZOOKEEPER_VERSION}"
create_dir data
append_to_file "tickTime=2000" "conf/zoo.cfg"
append_to_file "clientPort=2181" "conf/zoo.cfg"
append_to_file "dataDir=$(pwd)/data" "conf/zoo.cfg"
append_to_file "autopurge.purgeInterval=24" "conf/zoo.cfg"
append_to_file "autopurge.snapRetainCount=5" "conf/zoo.cfg"
popd
