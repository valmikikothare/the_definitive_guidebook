#!/usr/bin/env bash

set -e
script_dir=$(dirname $(readlink -f ${BASH_SOURCE[0]}))

# Copy cloudflare script over
sudo cp $script_dir/cloudflare_update_dns /usr/local/bin/

# Add cron job to crontab
job="* * * * * cloudflare_update_dns"
(crontab -u $(whoami) -l; echo "$job" ) | crontab -u $(whoami) -
