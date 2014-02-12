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

## Run poinstall script
```sh
wget https://raw2.github.com/slon1024/setup_storm/master/post_install.sh
source post_install.sh 
```
[VirtualBox]:https://www.virtualbox.org/
[storm]:http://storm.incubator.apache.org/
[vagrant]:http://www.vagrantup.com/
