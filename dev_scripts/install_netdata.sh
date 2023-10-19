#!/bin/bash

sudo apt-get install -y wget
wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --dont-wait --nightly-channel --claim-token $NETDATA_CLAIM_TOKEN --claim-rooms $NETDATA_CLAIM_ROOMS --claim-url https://app.netdata.cloud