/home/student/honeypot-1a/recycling_scripts/delete_container.sh
sh /home/student/honeypot-1a/recycling_scripts/firewall_rules.sh
sleep 5
systemctl start netdata
sleep 3
/home/student/honeypot-1a/recycling_scripts/check_container.sh
touch /tmp/reboot_flag