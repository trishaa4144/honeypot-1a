#!/bin/bash



containers=("server1" "server2" "server3" "server4" "server5")


for index in {0..4}; do
	
	container="${containers[$index]}"
	sudo lxc-destroy -n $container
done

rm /home/student/hpotinfo/*


