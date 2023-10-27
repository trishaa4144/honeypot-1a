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

if [[ -e /home/student/hpotinfo/mitm_location_$container_name ]]; then
    mitm_location=$(cat /home/student/hpotinfo/mitm_location_$container_name)

    # If auto access has been disabled at some point in the file, update the time file to
    # be the current time + 2 minutes (since this is checked every 2 minutes, effectively
    # kick out any attackers after 2-4 minutes, but provide enough grace period for
    # them to perform an attack.)
    if grep -q "Auto-access is now disabled" "$mitm_location"; then
        echo "$(date --iso-8601=seconds): Auto-access was disabled on $container_name, updating its recycle time." >> /home/student/check_logs/recycling_debug.log
        curr_time=$(date +"%s")
        seconds=$((2 * 60))
        goal_time=$((curr_time + seconds))
        echo "$container_name $goal_time" > /home/student/hpotinfo/time_$container_name
    fi
    else
        echo "$(date --iso-8601=seconds): Checked $mitm_location, No attacker has connected yet to $container_name" >> /home/student/check_logs/recycling_debug.log

fi
else
    echo "$(date --iso-8601=seconds): There is no mitm log associated with a container named $container_name" >> /home/student/check_logs/recycling_debug.log
fi