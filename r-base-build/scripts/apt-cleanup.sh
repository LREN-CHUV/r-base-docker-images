#!/bin/sh

apt-get autoremove -y
apt-get clean

rm -rf /var/lib/apt/lists/*
rm -rf /var/{cache,log}/*
mkdir -p /var/cache/apt/archives/partial
echo -n > /var/lib/apt/extended_states

rm -rf /tmp/downloaded_packages/ /tmp/*.rds
