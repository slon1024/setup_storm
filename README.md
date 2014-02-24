Setup storm
=========

Installing [storm] using vagrant.  
[Vagrant] allows:
> Create and configure lightweight,
> reproducible, 
> and portable development environments.
  

## Prerequisites
 - [VirtualBox]
 - [Vagrant]

## Create directory where located box
```sh
mkdir -p ~/vm/ubuntu1304-storm
cd ~/vm/ubuntu1304-storm
```

## Create a box
```sh
vagrant box add ubuntu1304-storm http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box
vagrant init ubuntu1304-storm
vagrant up
vagrant ssh
```

## Run postinstall script
```sh
curl -L https://raw2.github.com/slon1024/setup_storm/master/post_install.sh | bash
```

### Start ZooKeeper
```sh
zkServer.sh start
```
All commands:
```sh
zkServer.sh {start|start-foreground|stop|restart|status|upgrade|print-cmd}
```


### Start Kafka
```sh
kafka-server-start.sh $KAFKA_HOME/config/server.properties
```
If you want test it quickly you can start default producer and consumer
```sh
kafka-console-producer.sh --broker-list localhost:9092 --topic test
kafka-console-consumer.sh --zookeeper localhost:2181 --topic test --from-beginning
```


[VirtualBox]:https://www.virtualbox.org/
[storm]:http://storm.incubator.apache.org/
[vagrant]:http://www.vagrantup.com/
