#!/usr/bin/env bash

# Install and update Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
apt update -y
apt install -y docker-ce

# Enable remote access to the docker daemon
sed -i '/ExecStart/c\ExecStart=/usr/bin/dockerd -H 0.0.0.0:2375 -H fd://' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker

# Don't require sudo to run docker commands
usermod -a -G docker $USER