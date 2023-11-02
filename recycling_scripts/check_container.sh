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

containers=("server1" "server2" "server3" "server4" "server5")
ips=("128.8.238.194" "128.8.238.101" "128.8.238.173" "128.8.238.212" "128.8.238.206")
ports=("1297" "5420" "3956" "2145" "4532")


# Iterate through container/ip indices and call recycling script on
# each container-ip pair. Pass in a random value between 45 - 60 minutes.
# This value will be used to randomly assign the next time the container
# restarts, in a randomized way.

# Obtain random minute count between 15-20 minutes
# Recycles every 10-15 minutes by default (account for attacker staying in container
# for a long time)
minutes=$((RANDOM % 5 + 10))

for index in {0..4}; do
	echo "$(date --iso-8601=seconds): Checking all containers." >> /home/student/check_logs/recycling_debug.log
	# Grab container name, ip address from arrays
	container="${containers[$index]}"
	ip_address="${ips[$index]}"
	port_num="${ports[$index]}"

	# Check MITM logs for idle time and update time files if necessary
	/home/student/honeypot-1a/recycling_scripts/check_attacker_exit_idle.sh "$container"

	# Call recycling script on respective container
	/home/student/honeypot-1a/recycling_scripts/recycling_script.sh "$minutes" "$ip_address" "$container" "$port_num"
	sleep 10
done


