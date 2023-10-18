# honeypot-1a
HACS200 Honeypot - Group 1A - Honeybees

## Setup
1. Install Python 3
2. Download dependencies: `pip3 install -r requirements.txt`
3. Install MITM server `./recycling_scripts/mitm_download.sh`
4. Install forever `sudo npm install -g forever`
5. Crontab setup: 
    - Script `/recycling_scripts/check_container.sh` should run every minute.
    - Script `/recycling_scripts/firewall_rules.sh` should run @ reboot.
    - Script `/recycling_scripts/monitor_all.sh` should run every 15 minutes (Performs health check).
6. Netdata configuration: You will need to add your claim token and claim rooms token to your environment.
    - Modify ~/.zshrc to include the following lines
         - `export NETDATA_CLAIM_TOKEN=your_claim_token_here`
         - `export NETDATA_CLAIM_ROOMS=your_claim_rooms_token_here`
