Setup storm
=========

## Another repo where is setup the storm [cluster].


Installing [storm] using vagrant.  
[Vagrant] allows:
> Create and configure lightweight,
> reproducible, 
> and portable development environments.
  

## Prerequisites
 - [VirtualBox]
 - [Vagrant]


## Create virtual machine
```sh
vagrant up
```

## Log on
```sh
vagrant ssh
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
[cluster]:https://github.com/slon1024/vagrant-cluster-storm
