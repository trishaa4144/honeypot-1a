sh /home/student/honeypot-1a/recycling_scripts/firewall_rules.sh
sleep 5
systemctl start netdata
sleep 5
/home/student/honeypot-1a/recycling_scripts/check_container.sh
sleep 5
