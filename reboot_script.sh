sh /home/student/honeypot-1a/recycling_scripts/firewall_rules.sh
sleep 5
systemctl start netdata
sleep 5
/home/student/honeypot-1a/recycling_scripts/check_container.sh
sleep 5
(sudo crontab -l ; echo "*/5 * * * * /home/student/honeypot-1a/recycling_scripts/check_container.sh >> /home/student/check_logs/check_container_$(date --iso-8601=seconds).log")| sudo crontab -
(sudo crontab -l ; echo "*/15 * * * * /home/student/honeypot-1a/recycling_scripts/monitor_all.sh >> /home/student/monitor_logs/monitor_$(date --iso-8601=seconds).log")| sudo crontab -

touch /tmp/reboot_flag