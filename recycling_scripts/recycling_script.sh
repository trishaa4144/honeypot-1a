#!/bin/bash

# This script will take a number of minutes to run the container, the public IP address, 
# and the assigned container name as arguments. The script will then check to see if a container 
# is running and for how long it has been running. If the container has been running for the 
# specified amount of time, then the script will delete the networking rules between the container, 
# public IP, and MITM server and then destroy the container. It will immediately call itself 
# (the script) again with the randomized minute value passed in to restart the container with a 
# new random honey & expiration time. Otherwise, if the container is not running at all 
# (meaning the container was destroyed), create the container and establish the network rules between 
# the container, the public IP, and MITM server. However, if the container is running but not for 
# the allotted time, then the script will simply notify the user that the container is not ready to
# be recycled.


# Checks that 3 command line arguments (number of minutes, IP address, and container name)
if [[ $# -ne 3 ]]; then
  echo "Provide three shell arguments for the number of minutes to run the  container, the public IP address, and the assigned container name."
  exit 1
fi

num_min=$1
ext_ip=$2
container_name=$3
# Checks if “time” file exists for the current container
if [[ -e time_$container_name ]]; then
  # Read values from time file
  container=$(cat time_$container_name | cut -d' ' -f1)
  goal_time=$(cat time_$container_name | cut -d' ' -f2)
  curr_time=$(date +"%s")

  # Check if it’s time to recycle the container
  if [ $curr_time -lt $goal_time ]; then
    echo "container $container not ready to be recycled"
  else
    # Retrieve internal IP of container
    ip=$(sudo lxc-info -n "$container" -iH)

  # Copies all files in the .downloads directory of the container onto the host's directory named [container_name]_downloads
  sudo cp -r /var/lib/lxc/$container/rootfs/var/log/.downloads $(echo $container)_downloads_$(date --iso-8601=seconds)
  
  # Deletes the NAT rules that link the container to the MITM server
  sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 -- destination $ext_ip --jump DNAT --to-destination $containerIP

  sudo iptables --table nat --delete POSTROUTING --source $containerIP -- destination 0.0.0.0/0 --jump SNAT --to-source $ext_ip

  # Deletes the MITM NAT rule
  sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $ext_ip --protocol tcp --dport 22 --jump DNAT --to-destination 127.0.0.1:4567

  # Deletes the container entirely as it is ready to be recycled
  sudo lxc-stop -n $container_name
  sudo lxc-destroy -n $container_name
  # Log container stopping time and remove ‘time’ file
  echo "$container stopped at $(date --iso-8601=seconds)"
  rm time
fi

# Call the script on itself at the end here. This ensures that once a
# container is deleted, it immediately starts up another one.
./recycling_script.sh $num_min $ext_ip $container_name
else
  # Start a container with the ip address ($2), container name ($3)

  sudo lxc-create -n $container_name -t download -- -d ubuntu -r focal -a amd64

  sudo lxc-start -n container_name

  echo "$container_name started at $(date --iso-8601=seconds) with honey type $honey_type"

  # Perform logic for command poisoning on the honeypot
  ./poison_cmds.sh $container_name

  # Perform logic for moving random honey onto container
  # We will call external scripts to move the honey onto the
  # machine, and update the local language on the machine

  honey_type=$(shuf -n 1 -e english spanish russian chinese)
  ./customize_honeypot $container_name $honey_type

  curr_time=$(date +"%s")
  seconds=$(($1 * 60))
  goal_time=$((curr_time + seconds))

  # Create ‘time’ file with container name and goal time
  echo "$2 $goal_time" > time_$container_name

  container_ip=$(sudo lxc-info -n "$container" -iH)

  # Set up MITM server
  if [[ ! -d ~/mitm_logs ]]; then
    mkdir ~/mitm_logs
  fi

  sudo sysctl -w net.ipv4.conf.all.route_localnet=1
  sudo npm install -g forever

  sudo forever -l ~/mitm_logs/$container.log start ~/MITM/mitm.js -n $container -i $container_ip -p 4567 --auto-access --auto-access-fixed 3 --debug

  sudo ip addr add $ext_ip/16 brd + dev eth1

  # Makes it so the container can communicate back and forth with said external IP
  sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $ext_ip --jump DNAT --to-destination $container_ip

  sudo iptables --table nat --insert POSTROUTING --source $container_ip --destination 0.0.0.0/0 --jump SNAT --to-source $ext_ip

  # Sets up the SSH port forwarding
  sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination $ext_ip --protocol tcp --dport 22 --jump DNAT --to-destination 127.0.0.1:4567
fi

