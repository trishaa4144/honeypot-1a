#!/bin/bash

if [[ $# -lt 1 ]]
    echo "Please enter the name of the honeypot you want to check on"
    exit 1
fi

honeypot=$1

cpu_use=$( sudo lxc-info $honeypot | grep "CPU use" | colrm 1 16 )
memory_use=$( sudo lxc-info $honeypot | grep "Memory use" | colrm 1 16 )

echo "Current CPU use for $honeypot is: $cpu_use"
echo "Current memory use for $honeypot is: $memory_use"