#!/bin/bash


# This script will create fake wget and curl commands that will record the malware an attacker 
# downloads onto the container. It does so by creating new commands with the same name as wget 
# and curl and moves the original commands into a separate folder so that the script for the fake 
# commands can call the real commands.


# Make sure at least one argument, the name of the target container, is
# passed in
if [ $# -eq 0 ]
then
  echo "Provide container name."
  exit 1
fi

# Check if the container specified by the first argument exists
if [ $(sudo lxc-ls | grep -w $1 | wc -l) -eq 0 ]
then
  # If the container is not found, display an error message
  echo "Container not found."
  exit 2
fi

# Make a directory called .downloads in /var/log on the container, and give everyone execute 
# permissions in it
sudo lxc-attach -n "$1" -- mkdir /var/log/.downloads
sudo lxc-attach -n "$1" -- chmod o+x /var/log/.downloads

# Install wget in case the container doesn’t have it
sudo lxc-attach -n "$1" -- bash -c 'sudo apt-get install -y wget'

# Create a file with a script that creates the fake wget command, which
# sends the results of wget to .downloads then actually performs wget
sudo lxc-attach -n "$1" -- bash -c 'echo "#!/bin/bash" > f_wget && echo "r_wget \$@ -O /var/log/.downloads/\$(date --iso-8601=seconds) -q > /dev/null 2>&1" >> f_wget && echo "r_wget \$@" >> f_wget'

# Give everyone permission to use this fake command
sudo lxc-attach -n "$1" -- bash -c 'chmod o+x f_wget'

# Save a copy of the actual wget, so it can be called after the fake wget
sudo lxc-attach -n "$1" -- bash -c 'mv /usr/bin/wget /usr/bin/r_wget'

# Rename the fake command to the actual command, and add permissions
sudo lxc-attach -n "$1" -- bash -c 'mv f_wget /usr/bin/wget'
sudo lxc-attach -n "$1" -- bash -c 'chmod o+x /usr/bin/wget'

# Install curl in case the container doesn’t have it
sudo lxc-attach -n "$1" -- bash -c 'sudo apt-get install -y curl'

# Create a file with a script that creates the fake curl command, which
# Sends the results of curl to .downloads then actually performs curl
sudo lxc-attach -n "$1" -- bash -c 'echo "#!/bin/bash" > f_curl && echo "r_curl -o /var/log/.downloads/\$(date --iso-8601=seconds) \$@  -q > /dev/null 2>&1" >> f_curl && echo "r_curl \$@" >> f_curl'

# Give everyone permission to use this fake command
sudo lxc-attach -n "$1" -- bash -c 'chmod o+x f_curl'

# Save a copy of the actual curl, so it can be called after the fake curl
sudo lxc-attach -n "$1" -- bash -c 'mv /usr/bin/curl /usr/bin/r_curl'

# Rename the fake command to the actual command, and add permissions
sudo lxc-attach -n "$1" -- bash -c 'mv f_curl /usr/bin/curl'
sudo lxc-attach -n "$1" -- bash -c 'chmod o+x /usr/bin/curl'

# Here we will write logic to copy the files onto our host machine from
# the container. For this implementation, since the focus is on honeypot
# recycling, we have not included it, but we will expand on it
# in our monitoring / data collection scripts.



