#!/bin/bash

#set working directory

if [ -d /vagrant ]; then
    BASE="/vagrant"
else
    BASE="/ops"
fi

cd $BASE

echo "Installing latest docker"
curl -sSL https://get.docker.com/ubuntu/ | sudo sh

sudo apt-get install -y unzip jq node

echo "Downloading serf"
wget https://dl.bintray.com/mitchellh/serf/0.6.4_linux_amd64.zip
unzip 0.6.4_linux_amd64.zip
rm 0.6.4_linux_amd64.zip

echo "Downloading consul"
sudo docker pull progrium/consul

echo "Installing meteor"
curl https://install.meteor.com/ | sh

echo "Installing mcli tools"
curl https://raw.githubusercontent.com/practicalmeteor/meteor-mcli/master/bin/install-mcli.sh | bash

sudo apt-get upgrade -y

echo "Configuring cli tools"
mkdir -p $BASE/monk/.meteor/local
mkdir -p ~/monk/.meteor/local
sudo mount --bind /home/vagrant/monk/.meteor/local/ $BASE/monk/.meteor/local/

if [ -d /vagrant ]; then

    echo "Starting web interface"
    mkdir -p /vagrant/monk-opsweb/.meteor/local
    mkdir -p ~/ops/.meteor/local
    sudo mount --bind /home/vagrant/ops/.meteor/local/ /vagrant/monk-opsweb/.meteor/local/
    cd /vagrant/monk-opsweb
    nohup meteor 0<&- &>/dev/null &
    cd $BASE

    export MONGO_URL=127.0.0.1:3001/meteor
    echo "Linking serf to web interface"
else
    echo "Starting event handlers"
fi

nohup $BASE/serf agent -node listener -event-handler $BASE/serf-handler.sh 0<&- &>/dev/null &