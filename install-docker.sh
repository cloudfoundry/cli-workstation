#!/bin/bash

## Get the docker engine - community edition, for some reason
## From https://docs.docker.com/install/linux/docker-ce/debian/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
sudo apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

## Save yourself from using sudo for all docker commands
## From https://docs.docker.com/install/linux/linux-postinstall/
sudo groupadd docker
sudo usermod -aG docker $USER

## To clean up, run the following:
# sudo apt-get purge docker-ce
# sudo rm -rf /var/lib/docker
