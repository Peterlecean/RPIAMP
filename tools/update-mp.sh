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

ice_xml_original=$(cat /etc/icecast2/icecast.xml)
ice_xml_x=""
while IFS= read -r client_ip
do
  if [ -n "$client_ip" ]; then
    client_mp=$(curl --silent --connect-timeout 3 -s http://$client_ip:8000/status-json.xsl | jq -r 'getpath(["icestats","source","server_name"])')
    if [ -n "$client_mp" ]; then
      ice_xml_x+=$(echo "<icecast></icecast>" | xmlstarlet ed -s /icecast -t elem -n "relay" | xmlstarlet ed -s /icecast/relay -t elem -n "server" -v "$client_ip" | xmlstarlet ed -s /icecast/relay -t elem -n "port" -v "8000" | xmlstarlet ed -s /icecast/relay -t elem -n "mount" -v "/$client_mp" | xmlstarlet ed -s /icecast/relay -t elem -n "username" -v "admin" | xmlstarlet ed -s /icecast/relay -t elem -n "password" -v "test-password" | xmlstarlet ed -s /icecast/relay -t elem -n "relay-shoutcast-metadata" -v "0" | xmlstarlet ed -s /icecast/relay -t elem -n "on-demand" -v "0" | head -n-1 | tail -n +3)$'\n'
    fi
  fi
done < <(printf '%s\n' "$ovnips_alive")


ln=$(cat /etc/icecast2/icecast.xml | xmlstarlet ed -d /icecast/relay | xmlstarlet ed -s /icecast -t elem -n "relay" | grep -n '<relay/>' | cut -d : -f 1)

ice_xml_d=$(cat /etc/icecast2/icecast.xml | xmlstarlet ed -d /icecast/relay)
ice_xml=$(echo "$ice_xml_d" | xmlstarlet ed -s /icecast -t elem -n "relay" | head -n $((ln-1)))$'\n'$ice_xml_x$(echo "$ice_xml_d" | xmlstarlet ed -s /icecast -t elem -n "relay" | sed -n "$((ln+1))"',$p')

if [[ "$ice_xml" != "$ice_xml_original" ]]; then
  echo "$ice_xml" > /etc/icecast2/icecast.xml
  pkill -HUP icecast2
fi
