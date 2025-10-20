#!/bin/bash
sudo apt-get update -y &&
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
python3 \
python3-pip \
software-properties-common &&
echo "User data script completed at $(date)" > ~/user-data-complete.txt