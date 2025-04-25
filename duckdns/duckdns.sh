#!/bin/bash
echo url="https://www.duckdns.org/update?domains=rpiamp.duckdns.org&token=FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF&ip=" | curl -k -o /var/log/duck.log -K -