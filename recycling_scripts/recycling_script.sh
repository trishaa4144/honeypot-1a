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
if [[ $# -ne 4 ]]; then
  echo "Provide three shell arguments for the number of minutes to run the  container, the public IP address, the assigned container name, and the port number of the MITM server."
  exit 1
fi

num_min=$1
ext_ip=$2
container_name=$3
port_num=$4

honey_type=$(shuf -n 1 -e english spanish russian chinese)

# Checks if “time” file exists for the current container
if [[ -e /home/student/hpotinfo/time_$container_name ]]; then
  # Read values from time file
  goal_time=$(cat /home/student/hpotinfo/time_$container_name | cut -d' ' -f2)
  curr_time=$(date +"%s")

  # Check if it’s time to recycle the container
  if [ $curr_time -lt $goal_time ]; then
    echo "container $container_name not ready to be recycled"
    exit 0
  else
    # Add 10 minutes to time file for duration of honeypot destruction/cleanup process
    # This will prevent crontab from trying to recycle the honeypot twice concurrently.
    rm /home/student/hpotinfo/time_$container_name
    curr_time=$(date +"%s")
    seconds=$((10 * 60))
    goal_time=$((curr_time + seconds))
    echo "$container_name $goal_time" > /home/student/hpotinfo/time_$container_name
    
    # Retrieve internal IP of container
    container_ip=$(sudo lxc-info -n "$container_name" -iH)

    if [[ ! -d /home/student/malware_downloads/ ]]; then
      mkdir /home/student/malware_downloads/
    fi

    if [[ ! -d /home/student/malware_downloads/$(cat /home/student/hpotinfo/honey_$container_name) ]]; then
      mkdir /home/student/malware_downloads/$(cat /home/student/hpotinfo/honey_$container_name)
    fi

    # Copies all files in the .downloads directory of the container onto the host's directory named [container_name]_downloads
    sudo cp -r /var/lib/lxc/$container_name/rootfs/var/log/.downloads /home/student/malware_downloads/$(cat /home/student/hpotinfo/honey_$container_name)/$(date --iso-8601=seconds)
  
    # Deletes the NAT rules that link the container to the MITM server
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $ext_ip --jump DNAT --to-destination $container_ip

    sudo iptables --table nat --delete POSTROUTING --source $container_ip --destination 0.0.0.0/0 --jump SNAT --to-source $ext_ip

    # Deletes the MITM NAT rule
    sudo iptables --table nat --delete PREROUTING --source 0.0.0.0/0 --destination $ext_ip --protocol tcp --dport 22 --jump DNAT --to-destination 127.0.0.1:"$port_num"

    # Done this way because after the first instance is done, the container after that to be deleted will be shifted up to uid 0,
    # so on and so forth
    
    # DELETE LATER
    echo $(sudo forever list | grep -w $container_name | cut -d " " -f5 | sed 's/[][]//g')

    sudo forever stop $(sudo forever list | grep -w $container_name | cut -d " " -f5 | sed 's/[][]//g')
    
    # Deletes the container entirely as it is ready to be recycled
    sudo lxc-stop -n $container_name
    sudo lxc-destroy -n $container_name

    # Log container stopping time and remove ‘time’ file
    echo "$container_name stopped at $(date --iso-8601=seconds)"
    rm /home/student/hpotinfo/time_$container_name

    sleep 5

    # Call the script on itself at the end here. This ensures that once a
    # container is deleted, it immediately starts up another one.
    /home/student/honeypot-1a/recycling_scripts/recycling_script.sh $num_min $ext_ip $container_name $port_num

    exit 0
  fi

else
  # Start a container with the ip address ($2), container name ($3)

  sudo lxc-create -n $container_name -t download -- -d ubuntu -r focal -a amd64

  sudo lxc-start -n $container_name

  echo "$container_name started at $(date --iso-8601=seconds) with honey type $honey_type"
  sleep 5

  # Perform logic for command poisoning on the honeypot
  /home/student/honeypot-1a/recycling_scripts/poison_cmds.sh $container_name

  # Perform logic for moving random honey onto container
  # We will call external scripts to move the honey onto the
  # machine, and update the local language on the machine

  /home/student/honeypot-1a/recycling_scripts/customize_honeypot.sh $container_name $honey_type

  curr_time=$(date +"%s")
  seconds=$(($1 * 60))
  goal_time=$((curr_time + seconds))

  # Create ‘time’ file with container name and goal time
  echo "$container_name $goal_time" > /home/student/hpotinfo/time_$container_name

  echo $honey_type > /home/student/hpotinfo/honey_$container_name

  container_ip=$(sudo lxc-info -n "$container_name" -iH)

  # Set up MITM server
  if [[ ! -d /home/student/mitm_logs/ ]]; then
    mkdir /home/student/mitm_logs/
  fi

  if [[ ! -d /home/student/mitm_logs/"$honey_type" ]]; then
    mkdir /home/student/mitm_logs/"$honey_type"
  fi

  date=$(date --iso-8601=seconds)

  sudo sysctl -w net.ipv4.conf.all.route_localnet=1
  sudo npm install -g forever

  sudo forever -l /home/student/mitm_logs/"$honey_type"/"$container_name"\_"$date".log start /home/student/MITM/mitm.js -n "$container_name" -i "$container_ip" -p "$port_num" --auto-access --auto-access-fixed 3 --debug

  sudo ip addr add "$ext_ip"/24 brd + dev eth1

  # Makes it so the container can communicate back and forth with said external IP
  sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination "$ext_ip" --jump DNAT --to-destination "$container_ip"

  sudo iptables --table nat --insert POSTROUTING --source "$container_ip" --destination 0.0.0.0/0 --jump SNAT --to-source "$ext_ip"

  # Sets up the SSH port forwarding
  sudo iptables --table nat --insert PREROUTING --source 0.0.0.0/0 --destination "$ext_ip" --protocol tcp --dport 22 --jump DNAT --to-destination 127.0.0.1:"$port_num"
  exit 0
fi

