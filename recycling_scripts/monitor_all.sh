#!/bin/bash

# Defines containers[] as an array with the same names
# as our honeypot. The names used here are simply example
# names; come deployment time, we will use the same names
# as our honeypot containers.
containers=(“server1”, “server2”, “server3”, “server4”)

# For every honeypot
for index in {0..3}; do
	# Grab its name from the array containers[]
	container="${containers[$index]}"
    # Run the monitoring script on the selected honeypot
    ./monitoring.sh $container
done	

