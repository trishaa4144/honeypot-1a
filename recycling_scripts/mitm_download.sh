#!/bin/bash

# This script's only purpose is to download the MITM server software onto the host
#   Make sure to run this first BEFORE ANYTHING ELSE!!!
#   Also make sure that openssh-server is installed onto the container first before attempting to run the MITM server
git clone https://github.com/UMD-ACES/MITM
cd ./MITM
sudo ./install.sh