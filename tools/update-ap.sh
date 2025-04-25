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

ovnipsnas_alive=""
while IFS= read -r client_ip
do
  if [ -n "$client_ip" ]; then
    client_mp=$(curl --silent --connect-timeout 3 -s http://$client_ip | grep -i openmediavault)
    if [ -n "$client_mp" ]; then
      ovnipsnas_alive+=$client_ip
      break
    fi
  fi
done < <(printf '%s\n' "$ovnips_alive")

apache_config_original=$(cat /etc/apache2/sites-available/000-default.conf)
apache_config="ServerName www.example.com"$'\n'
apache_config+="<VirtualHost *:80>"$'\n'
apache_config+="  ServerAdmin webmaster@example.com"$'\n'
apache_config+="  ServerName www.example.com"$'\n'
apache_config+="  DocumentRoot /var/www/html"$'\n'
apache_config+="  ErrorLog ${APACHE_LOG_DIR}/error.log"$'\n'
apache_config+="  CustomLog ${APACHE_LOG_DIR}/access.log combined"$'\n'
apache_config+=$'\n'
apache_config+="  ProxyPass /shell/server/ http://127.0.0.1:4200/"$'\n'
apache_config+="  ProxyPassReverse /shell/server/ http://127.0.0.1:4200/"$'\n'
apache_config+=$'\n'
if [ -n "$ovnipsnas_alive" ]; then
  apache_config+="  ProxyPass /omv/ http://$ovnipsnas_alive/"$'\n'
  apache_config+="  ProxyPassReverse /omv/ http://$ovnipsnas_alive/"$'\n'
  apache_config+=$'\n'
  apache_config+="  ProxyPass /shell/nas/ http://$ovnipsnas_alive:21000/"$'\n'
  apache_config+="  ProxyPassReverse /shell/nas/ http://$ovnipsnas_alive:21000/"$'\n'
  apache_config+=$'\n'
fi

while IFS= read -r client_ip
do
  if [ -n "$client_ip" ]; then
    client_mp=$(curl --silent --connect-timeout 3 -s http://$client_ip:8000/status-json.xsl | jq -r 'getpath(["icestats","source","server_name"])')
    if [ -n "$client_mp" ]; then
      apache_config+="  ProxyPass /shell/$client_mp/ http://$client_ip:21000/"$'\n'
      apache_config+="  ProxyPassReverse /shell/$client_mp/ http://$client_ip:21000/"$'\n'
      apache_config+=$'\n'
#      apache_config+="  ProxyPass /icecast/$client_mp/ http://$client_ip:8000/"$'\n'
#      apache_config+="  ProxyPassReverse /icecast/$client_mp/ http://$client_ip:8000/"$'\n'
#      apache_config+=$'\n'
      apache_config+="  <Location /OpenWebRX/$client_mp/ >"$'\n'
      apache_config+="    ProxyPass http://$client_ip:8073/"$'\n'
      apache_config+="    ProxyPassReverse http://$client_ip:8073/"$'\n'
      apache_config+="    RewriteEngine on"$'\n'
      apache_config+="    RewriteCond %{HTTP:CONNECTION} Upgrade$ [NC]"$'\n'
      apache_config+="    Order allow,deny"$'\n'
      apache_config+="    Allow from all"$'\n'
      apache_config+="  </Location>"$'\n'
      apache_config+="  <Location /OpenWebRX/$client_mp/ws/ >"$'\n'
      apache_config+="    ProxyPass ws://$client_ip:8073/ws/"$'\n'
      apache_config+="    ProxyPassReverse ws://$client_ip:8073/ws/"$'\n'
      apache_config+="    RewriteEngine on"$'\n'
      apache_config+="    RewriteCond %{HTTP:CONNECTION} Upgrade$ [NC]"$'\n'
      apache_config+="  </Location>"$'\n'
      apache_config+=$'\n'
    fi
  fi
done < <(printf '%s\n' "$ovnips_alive")
apache_config+="</VirtualHost>"
if [[ "$apache_config" != "$apache_config_original" ]]; then
  echo "$apache_config" > /etc/apache2/sites-available/000-default.conf
  systemctl restart apache2
  #apachectl -k graceful
fi
