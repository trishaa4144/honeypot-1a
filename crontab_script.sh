*/5 * * * * ~/honeypot-1a/recycling_scripts/check_container.sh >> ~/check_logs/check_container_$(date --iso-8601=seconds).log
@reboot ~/honeypot-1a/recycling_scripts/check_container.sh
@reboot ~/honeypot-1a/recycling_scripts/firewall_rules.sh
*/15 * * * * ~/honeypot-1a/recycling_scripts/monitor_all.sh >> ~/monitor_logs/monitor_$(date --iso-8601=seconds).log
