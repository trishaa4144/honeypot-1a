# This crontab script will run the check_container.sh script every five minutes. It will also run the
# check_container.sh script to ensure all honeypot containers will automatically restart after a full
# reboot of the host. Additionally, we also called the firewall_rules.sh script to be called at every 
# reboot to make sure our baseline firewall rules will be automatically re-applied after full reboot 
# of the host. Lastly, we will run the monitor_all.sh script every 15 minutes to monitor the states of 
# our honeypots.  
@reboot /home/student/honeypot-1a/reboot_script.sh
*/5 * * * * /home/student/honeypot-1a/recycling_scripts/flagged_check_container.sh >> /home/student/check_logs/check_container_$(date --iso-8601=seconds).log

# */15 * * * * /home/student/honeypot-1a/recycling_scripts/monitor_all.sh >> /home/student/monitor_logs/monitor_$(date --iso-8601=seconds).log