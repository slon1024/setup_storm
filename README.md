Setup storm
=========

Installing [storm] using vagrant.  
[Vagrant] allows:
> Create and configure lightweight,
> reproducible, 
> and portable development environments.
  

## Create directory where located box
```sh
mkdir -p ~/vm/ubuntu1304-storm
cd ~/vm/ubuntu1304-storm
```

## Create a box
```sh
vagrant box add ubuntu1304-storm http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-i386-vagrant-disk1.box
vagrant up
vagrant ssh
```

## Run poinstall script
```sh
wget https://raw2.github.com/slon1024/setup_storm/master/postinstall.sh
source postinstall.sh 
```

[storm]:http://storm.incubator.apache.org/
[vagrant]:http://www.vagrantup.com/
