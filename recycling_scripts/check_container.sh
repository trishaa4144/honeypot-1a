#!/bin/bash

# This script will run every 5 minutes via crontab scheduling. 
# It will check if each container has run for a random duration of time between 45 minutes 
# and 60 minutes (inclusive). This script will be run in the crontab and will run the 
# recycling_script script within it in order to check each honeypot to see if the honeypot 
# should be recycled (deleted and reconfigured) if the duration of time randomly chosen has passed. 

# Define container names and IP names. The containers have constant
# names server1, server2, server3, server4, and IPs ip1, ip2, ip3, ip4
# for the purpose of this implementation. However, when deploying our 
# honeypots, we can easily modify these two lines with correct names. 
containers=(“server1”, “server2”, “server3”, “server4”)
ips=(“ip1”,“ip2”,“ip3”,“ip4”)

# Iterate through container/ip indices and call recycling script on
# each container-ip pair. Pass in a random value between 45 - 60 minutes.
# This value will be used to randomly assign the next time the container
# restarts, in a randomized way.
for index in {0..3}; do
	# Grab container name, ip address from arrays
	container="${containers[$index]}"
	ip_address="${ips[$index]}"

	# Obtain random minute count between 45-60 minutes
	minutes=$((RANDOM % 16 + 45))

	# Call recycling script on respective container
	./recycling_script.sh "$minutes" "$ip_address" "$container"
done	
