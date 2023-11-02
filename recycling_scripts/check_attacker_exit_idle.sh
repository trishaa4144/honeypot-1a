# Checks for command line arguments (container name)
if [[ $# -ne 1 ]]; then
  echo "Provide the name of the container."
  exit 1
fi

container_name=$1
echo "$(date --iso-8601=seconds): MITM check - Checking MITM log for attackers in $container_name." >> /home/student/check_logs/recycling_debug.log

if [[ -e /home/student/hpotinfo/mitm_location_$container_name ]]; then
    mitm_location=$(cat /home/student/hpotinfo/mitm_location_$container_name)
    time_line=$(grep "Attacker closed the connection" "$mitm_location")    

    # If auto access has been disabled at some point in the file, update the time file to
    # be the current time + 2 minutes (since this is checked every 2 minutes, effectively
    # kick out any attackers after 2-4 minutes, but provide enough grace period for
    # them to perform an attack.)
    if [[ -n $time_line ]]; then
        time=$(echo "$time_line" | awk '{print $1, $2}')
        time_unix=$(date -d "$time" "+%s")
        curr_time=$(date +"%s")
        seconds=$((2 * 60))
        threshold_time=$((curr_time - seconds))
        if [[ $time_unix -le $threshold_time ]]; then
            echo "$(date --iso-8601=seconds): MITM check - Auto-access was disabled on $container_name, updating its recycle time." >> /home/student/check_logs/recycling_debug.log
            echo "$container_name $curr_time" > /home/student/hpotinfo/time_$container_name
        else
            echo "$(date --iso-8601=seconds): MITM check - Auto-access was less than 2 minutes ago on $container_name, no need to recycle yet." >> /home/student/check_logs/recycling_debug.log
        fi
    else
        echo "$(date --iso-8601=seconds): MITM check - Checked $mitm_location, No attacker has connected yet to $container_name" >> /home/student/check_logs/recycling_debug.log
    fi

else
    echo "$(date --iso-8601=seconds): MITM check - There is no mitm log location associated with a container named $container_name" >> /home/student/check_logs/recycling_debug.log
fi