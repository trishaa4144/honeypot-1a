# This script should be integrated within the for-loop in check_container.sh
# Take in the MITM log file name and time file path (This could hypothetically also 
# be parsed from sudo forever list). Parse the log for indication that the attacker exited.
# If the attacker has exited, replace the time file with the current time.
# If there is no indication of exit, but there is indication that the attacker entered and
# is "idle", then replace time file with the current time + 2 or 5 minutes.
# Also, we will need to save the name of the MITM log corresponding to the server/container
# somehow in the recycling script.

# "Attacker connected" -> grep the time from the MITM log and see 
# "Attacker closed the connection" -> set time file to current time

# Alternatively, just check when the MITM log was last modified and if it was not that long ago,
# recycle the container (update the time file to right now)

# Checks for command line arguments (container name)
if [[ $# -ne 1 ]]; then
  echo "Provide the name of the container."
  exit 1
fi

container_name=$1
echo "$(date --iso-8601=seconds): MITM check - Checking MITM log for attackers in $container_name." >> /home/student/check_logs/recycling_debug.log

if [[ -e /home/student/hpotinfo/mitm_location_$container_name ]]; then
    mitm_location=$(cat /home/student/hpotinfo/mitm_location_$container_name)
    time_line=$(grep "Auto-access is now disabled" "$mitm_location")    

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