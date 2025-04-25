#!/bin/bash
ovnips=$(cat /var/log/openvpn/openvpn-status.log | sed -n '/ROUTING TABLE/,/GLOBAL STATS/p' | tail -n+3 | head -n-1 | grep -o "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
ovnips_alive=""
while IFS= read -r client_ip
do
  ping_result=$(ping -w 1 -W 1 -c 1 $client_ip 2>&1)
  ping_status=$?
  if [ $ping_status -eq 0 ]; then
    ovnips_alive+=$client_ip$'\n'
  fi
done < <(printf '%s\n' "$ovnips")
echo "$ovnips_alive"
