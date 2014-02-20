#!/bin/bash

ZOOKEEPER_VERSION=3.4.5
ZEROMQ_VERSION=4.0.3
STORM_VERSION=0.9.0.1

NIMBUS=nimbus1
SUPERVISORS=(supervisor1 supervisor2 supervisor3)
ZOOKEEPERS=(zookeeper1 zookeeper2 zookeeper3)

LIB_PATH='/usr/lib'

create_dir(){
  PATH_TO_FILE=$1
  [ -d $PATH_TO_FILE ] || mkdir $PATH_TO_FILE
}

download() {
  URI=$1
  BASE_NAME=$(basename $URI)
  [ -d  ${BASE_NAME%*.tar.gz} ] || wget $URI
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

add_var_to_path() {
  VAR_NAME=$1
  VAR_VAL=$2

  append_to_file "$VAR_NAME=$VAR_VAL" "/etc/profile"
  append_to_file "PATH=\$PATH:\$${VAR_NAME}/bin" "/etc/profile"
  append_to_file "export $VAR_NAME" "/etc/profile"
  append_to_file 'export PATH' "/etc/profile"

  . /etc/profile
}

sudo aptitude install -y  build-essential gcc g++ uuid-dev libtool git pkg-config autoconf

### Install Java ###
if [ -x "/usr/bin/java" ]; then
  echo -e "\e[32mJava currently is installed\e[0m"
else
  sudo add-apt-repository -y ppa:webupd8team/java
  sudo apt-get update -y
  echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
  sudo aptitude install -y oracle-java7-installer
  sudo update-java-alternatives -s java-7-oracle
  sudo apt-get install oracle-java7-set-default

  add_var_to_path 'JAVA_HOME' '/usr/lib/jvm/java-7-oracle'
  echo -e "\e[32mjava7 installing succeed\e[0m"
fi

create_dir tools
pushd tools

### ZooKeeper ###
ZOOKEEPER_DIR_NAME="zookeeper-${ZOOKEEPER_VERSION}"
ZOOKEEPER_LIB_PATH="$LIB_PATH/zookeeper/${ZOOKEEPER_DIR_NAME}"
if [ -d "$ZOOKEEPER_LIB_PATH" ]
then
  echo -e "\e[32mZookeeper currently is installed\e[0m"
else
  #http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org
  ZOOKEEPER_URI="http://ftp.task.gda.pl/pub/www/apache/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz"
  download $ZOOKEEPER_URI

  if [ ! -f "zookeeper-${ZOOKEEPER_VERSION}.tar.gz" ]; then
    echo -e "\e[31mProblem with download $ZOOKEEPER_URI\e[0m"
    exit
  fi

  uncompress "zookeeper-${ZOOKEEPER_VERSION}.tar.gz"
  pushd "${ZOOKEEPER_DIR_NAME}"
  create_dir data
  append_to_file "tickTime=2000" "conf/zoo.cfg"
  append_to_file "clientPort=2181" "conf/zoo.cfg"
  append_to_file "dataDir=$(pwd)/data" "conf/zoo.cfg"
  append_to_file "autopurge.purgeInterval=24" "conf/zoo.cfg"
  append_to_file "autopurge.snapRetainCount=5" "conf/zoo.cfg"

  for item in ${ZOOKEEPERS[*]}
  do
    append_to_file "127.0.0.1 $item" "/etc/hosts"
  done
   
  popd  
  sudo mkdir -p "$LIB_PATH/zookeeper"
  sudo mv $ZOOKEEPER_DIR_NAME "$ZOOKEEPER_LIB_PATH"
  add_var_to_path 'ZOOKEEPER_HOME' "$ZOOKEEPER_LIB_PATH" 
  echo -e "\e[32mzookeeper-${ZOOKEEPER_VERSION} installing succeed\e[0m"
fi

### ZeroMQ ###
if [ -d "zeromq-${ZEROMQ_VERSION}" ]; then
  echo -e "\e[32mZeroMQ currently is installed\e[0m"
else
  ZEROMQ_DIR_NAME="zeromq-${ZEROMQ_VERSION}"
  ZEROMQ_URI="http://download.zeromq.org/${ZEROMQ_DIR_NAME}.tar.gz"
  download $ZEROMQ_URI

  if [ ! -f "${ZEROMQ_DIR_NAME}.tar.gz" ]; then
    echo -e "\e[31mProblem with download $ZEROMQ_URI\e[0m"
    exit
  fi
  
  uncompress "${ZEROMQ_DIR_NAME}.tar.gz"

  pushd "${ZEROMQ_DIR_NAME}"
  ./configure
  make
  sudo make install
  popd
  echo -e "\e[32mzeromq-${ZEROMQ_VERSION} installing succeed\e[0m"
fi

### jzmq ###
if [ -d jzmq ]; then
  echo -e "\e[32mjzmq currently is installed\e[0m"
else
  JZMQ_URI=https://github.com/nathanmarz/jzmq.git
  git clone $JZMQ_URI
  if [ -d jzmq ]; then
    echo -e "\e[31mProblem with download $JZMQ_URI\e[0m"
    exit
  fi
  
  pushd jzmq
  sed -i 's/classdist_noinst.stamp/classnoinst.stamp/g' src/Makefile.am
  ./autogen.sh
  ./configure
  make
  sudo make install
  popd
  echo -e "\e[32mjzmq installing succeed\e[0m"
fi

### Storm ###
STORM_DIR_NAME="storm-$STORM_VERSION"
STORM_LIB_PATH="$LIB_PATH/storm/${STORM_DIR_NAME}"
if [ -d $STORM_LIB_PATH ]; then
  echo -e "\e[32mStorm currently is installed\e[0m"
else
  STORM_URI="https://dl.dropboxusercontent.com/s/tqdpoif32gufapo/${STORM_DIR_NAME}.tar.gz"
  download $STORM_URI
  if [ ! -f "${STORM_DIR_NAME}.tar.gz" ]; then
    echo -e "\e[31mProblem with download $STORM_URI\e[0m"
    exit
  fi
  uncompress "${STORM_DIR_NAME}.tar.gz"

  pushd "${STORM_DIR_NAME}"

  LOCAL_DIR=local_dir
  create_dir $LOCAL_DIR

  append_to_file "storm.zookeeper.servers:" "conf/storm.yaml"
  for item in ${ZOOKEEPERS[*]}
  do
    append_to_file "  - \"$item\"" "conf/storm.yaml"
  done

  append_to_file "nimbus.host: \"${NIMBUS}\"" "conf/storm.yaml"
  append_to_file 'nimbus.childopts: "-Xmx1024m -Djava.net.preferIPv4Stack=true"' "conf/storm.yaml"

  append_to_file 'ui.port: 8181' "conf/storm.yaml"
  append_to_file 'ui.childopts: "-Xmx768m -Djava.net.preferIPv4Stack=true"' "conf/storm.yaml"

  append_to_file 'supervisor.childopts: "-Djava.net.preferIPv4Stack=true"' "conf/storm.yaml"
  append_to_file 'worker.childopts: "-Xmx768m -Djava.net.preferIPv4Stack=true"' "conf/storm.yaml"

  append_to_file "storm.local.dir: \"$(pwd)/$LOCAL_DIR\"" "conf/storm.yaml"

  append_to_file "127.0.0.1 $NIMBUS" "/etc/hosts"
  for item in ${SUPERVISORS[*]}
  do
    append_to_file "127.0.0.1 $item" "/etc/hosts"
  done

  popd

  sudo mkdir -p "$LIB_PATH/storm"
  sudo mv $STORM_DIR_NAME "$STORM_LIB_PATH"
  add_var_to_path 'STORM_HOME' "$STORM_LIB_PATH"
  echo -e "\e[32mstorm-${STORM_VERSION} installing succeed\e[0m"
fi

### Maven ###
sudo aptitude install -y maven

### RVM ###
if [ -d ~/.rvm ]; then
  echo -e "\e[32mrvm currently is installed\e[0m"
else
  \curl -sSL https://get.rvm.io | bash -s stable
  if [ ! -d ~/.rvm ]; then
    echo -e "\e[31mProblem with download rvm\e[0m"
    exit
  fi
  source ~/.rvm/scripts/rvm
  echo -e "\e[32mrvm installing succeed\e[0m"
fi

### RedStorm ###
sudo gem install redstorm

### Lein ###
LEIN_BIN_PATH=/usr/bin/lein
if [ -x $LEIN_BIN_PATH ]
then
  echo -e "\e[32mLein currently is installed\e[0m"
else
  pushd /usr/bin
  LEIN_URI=https://raw.github.com/technomancy/leiningen/stable/bin/lein
  sudo wget $LEIN_URI
  if [ ! -f lein ]; then
    echo -e "\e[31mProblem with download $LEIN_URI\e[0m"
    exit
  fi
  sudo chmod +x lein
  ./lein
  popd
  echo -e "\e[32mlein installing succeed\e[0m"
fi

### storm-deploy ###
if [ -d "storm-deploy"]
then
  echo -e "\e[32mstorm-deploy currently is installed\e[0m"
else
  STORMDEPLOY_URI=git://github.com/nathanmarz/storm-deploy.git
  STORMDEPLOY_DIR_NAME=storm-deploy
  git clone 
  if [ ! -d $STORMDEPLOY_DIR_NAME ]; then
    echo -e "\e[31mProblem with download $STORMDEPLOY_URI\e[0m"
    exit
  fi
  pushd $STORMDEPLOY_DIR_NAME
  lein deps
  popd
  echo -e "\e[32mstorm-deploy installing succeed\e[0m"
fi


rm -f *.tar.gz
popd
