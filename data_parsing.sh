#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Please enter a valid language of the honeypot to assess"
    exit 1
fi

language=$1
current_date=$(date --iso-8601)
# total_unique_ips=$() # ADD THE COMMAND HERE

if [[ ! -d /home/student/data/ ]]; then
    mkdir /home/student/data/
fi

if [[ ! -d /home/student/data/$language ]]; then
    mkdir /home/student/data/$language
fi

# go into the mitm_logs folder of the particular language we want to assess
cd /home/student/mitm_logs/$language

# gets number of unique IP addresses of attackers & counts how many times each appears
cat * | grep "Attacker connected" | cut -d " " -f8 | sort | uniq -c | sort -nr > /home/student/data/$language/ips_$current_date.file

# gets all unique interactive commands entered by the attacker (and the number of times they were used)
cat * | grep -w "line from reader" | cut -d " " -f9- | sort | uniq -c | sort -rn > /home/student/data/$language/interactive_$current_date.file

# gets all unique noninteractive commands entered by the attacker (and the number of times they were used)
cat * | grep -w "Noninteractive" | cut -d " " -f10- | sort | uniq -c | sort -rn > /home/student/data/$language/noninteractive_$current_date.file

