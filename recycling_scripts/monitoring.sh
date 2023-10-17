#!/bin/bash

# This script will check the state, CPU usage, memory use, and
# number of attackers in a single honeypot. It will do so
# by taking in the honeypot's name as an argument and
# using lxc-info to check the first three indicators
# and then using MITM session streams to check the
# last indicator.

# Takes in one argument which is the name of the honeypot
if [[ $# -lt 1 ]]; then
    echo "Please enter the name of the honeypot you want to check on"
    exit 1
fi

# Stores that argument in the variable honeypot
honeypot=$1

# Runs the command `sudo lxc-info` for that honeypot and extracts 
# the state of the honeypot
state=$( sudo lxc-info $honeypot | grep "State" | colrm 1 16 )
# Runs the command `sudo lxc-info` for that honeypot and extracts 
# the CPU usage of the honeypot
cpu_use=$( sudo lxc-info $honeypot | grep "CPU use" | colrm 1 16 )
# Runs the command `sudo lxc-info` for that honeypot and extracts 
# the memory usage of the honeypot
memory_use=$( sudo lxc-info $honeypot | grep "Memory use" | colrm 1 16 )

#Prints out the state, CPU use, and memory use for the honeypot
echo "Current state of $honeypot: $state"
echo "Current CPU use for $honeypot: $cpu_use"
echo "Current memory use for $honeypot: $memory_use"

# Here is where we will put the logic of checking for the number of attackers
# in the honeypots. We will do so by using MITM session streams for each
# honeypot and checking for the session open/session closed indicators.
# An alternative way to do this would be to check the ssh auth.log files.