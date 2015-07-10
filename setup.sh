#!/bin/sh

# Install Docker (https://docs.docker.com/installation/ubuntulinux/)
# then run this script to complete the installation of tools used in this project.

sudo /bin/sh -c "curl -L https://github.com/docker/compose/releases/download/1.3.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod a+x /usr/local/bin/docker-compose

sudo /bin/sh -c "curl -L https://github.com/harbur/captain/releases/download/v0.4.0/captain > /usr/local/bin/captain"
sudo chmod a+x /usr/local/bin/captain
