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