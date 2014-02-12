#!/bin/bash

ZOOKEEPER_VERSION=3.4.5
ZEROMQ_VERSION=4.0.3
STORM_VERSION=0.9.0.1

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
  grep -q "${LINE}" ${PATH_TO_FILE} || echo ${LINE} | sudo tee -a ${PATH_TO_FILE}
}


sudo aptitude install -y  build-essential gcc g++ uuid-dev libtool git pkg-config autoconf

### Install Java ###
if [ -x "/usr/bin/java" ]
then
  java -version
else
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo apt-get update -y
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
  sudo aptitude install -y oracle-java7-installer
  sudo update-java-alternatives -s java-7-oracle
  sudo apt-get install oracle-java7-set-default
fi

append_to_file 'JAVA_HOME=/usr/lib/jvm/java-7-oracle' "/etc/profile"
append_to_file 'PATH=$PATH:$HOME/bin:$JAVA_HOME/bin' "/etc/profile"
append_to_file 'export JAVA_HOME' "/etc/profile"
append_to_file 'export PATH' "/etc/profile"
. /etc/profile



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


### ZeroMQ ###
download "http://download.zeromq.org/zeromq-${ZEROMQ_VERSION}.tar.gz"
uncompress "zeromq-${ZEROMQ_VERSION}.tar.gz" 

pushd "zeromq-${ZEROMQ_VERSION}"
./configure
make
sudo make install
popd


### jzmq ###
[ -d jzmq ] || git clone https://github.com/nathanmarz/jzmq.git
pushd jzmq
sed -i 's/classdist_noinst.stamp/classnoinst.stamp/g' src/Makefile.am
./autogen.sh
./configure
make
sudo make install
popd


### Storm ###
download "https://dl.dropboxusercontent.com/s/tqdpoif32gufapo/storm-${STORM_VERSION}.tar.gz"
uncompress "storm-${STORM_VERSION}.tar.gz"

rm *.tar.gz
popd