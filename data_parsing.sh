#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Please enter a valid language of the honeypot to assess"
    exit 1
fi

language=$1
current_date=$(date --iso-8601)

if [[ ! -d /home/student/data/ ]]; then
    mkdir /home/student/data/
fi

if [[ ! -d /home/student/data/$language ]]; then
    mkdir /home/student/data/$language
fi

if [[ ! -d /home/student/data/$language/$current_date ]]; then
    mkdir /home/student/data/$language/$current_date
fi

# go into the mitm_logs folder of the particular language we want to assess
cd /home/student/mitm_logs/$language

# counts all unique IPs
total_unique_ips=$(cat *$current_date* | grep "Attacker connected" | cut -d' ' -f8 | sort | uniq | wc -l)

echo "Total number of unique IPs: $total_unique_ips" >> /home/student/data/$language/$current_date/ips.file
# gets number of unique IP addresses of attackers & counts how many times each appears on the current date
cat *$current_date* | grep "Attacker connected" | cut -d " " -f8 | sort | uniq -c | sort -nr >> /home/student/data/$language/$current_date/ips.file

# gets the timestamp & interactive command entered in all sessions on the current date
cat *$current_date* | grep -w "line from user" | colrm 1 11 | colrm 14 49 >> /home/student/data/$language/$current_date/interactive.file

# gets the timestamp & noninteractive command entered in all sessions on the current date
cat *$current_date* | grep -w "Noninteractive" | colrm 1 11 | colrm 14 68 >> /home/student/data/$language/$current_date/noninteractive.file

# finally, gets the # of sessions & # of successful logins & puts them in the same file
logins=$(cat *"$current_date"* | grep -w "LXC-Auth" | wc -l)
sessions=$(ls *"$current_date"* | wc -l)

echo "Number of successful logins: $logins" >> /home/student/data/$language/$current_date/session_logins.file
echo "Number of sessions on $current_date: $sessions" >> /home/student/data/$language/$current_date/session_logins.file

