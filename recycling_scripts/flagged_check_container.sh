#!/bin/bash

if [[ -e /tmp/reboot_flag ]]
then
    echo "$(date --iso-8601=seconds): Flag exists. Checking the containers." >> /home/student/check_logs/recycling_debug.log
    /home/student/honeypot-1a/recycling_scripts/check_container.sh
fi