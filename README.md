# honeypot-1a
HACS200 Honeypot - Group 1A - Honeybees

## Setup
1. Install Python 3
2. Download dependencies: `pip3 install requirements.txt`
3. Install MITM server `./recycling_scripts/mitm_download.sh`
4. Crontab setup: 
    - Script `/recycling_scripts/check_container.sh` should run every minute.
    - Script `/recycling_scripts/firewall_rules.sh` should run @ reboot.