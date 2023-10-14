#!/bin/bash

#Takes in one argument which is the name of the honeypot
if [[ $# -lt 1 ]]
    echo "Please enter the name of the honeypot you want to check on"
    exit 1
fi

#Stores that argument in the variable honeypot
honeypot=$1

#Runs the command `sudo lxc-info` for that honeypot and extracts the state of the honeypot
state=$( sudo lxc-info $honeypot | grep "State" | colrm 1 16 )
#Runs the command `sudo lxc-info` for that honeypot and extracts the CPU usage of the honeypot
cpu_use=$( sudo lxc-info $honeypot | grep "CPU use" | colrm 1 16 )
#Runs the command `sudo lxc-info` for that honeypot and extracts the memory usage of the honeypot
memory_use=$( sudo lxc-info $honeypot | grep "Memory use" | colrm 1 16 )

#Prints out the state, CPU use, and memory use for the honeypot
echo "Current state of $honeypot: $state"
echo "Current CPU use for $honeypot: $cpu_use"
echo "Current memory use for $honeypot: $memory_use"