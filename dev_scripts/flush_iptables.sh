#!/bin/bash

sudo iptables -F # flush all chains
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X # delete all chains

# Credit:
# https://serverfault.com/questions/166908/iptables-command-to-clear-all-existing-rules