#!/bin/bash

URL='WEBHOOKPLACEHOLDER'

source /opt/dizcord/colours.dec

MESSAGE="**HRNAME** server reanimating now."

date +%s > "/opt/dizcord/times/ININAME-start.time"
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" "$URL"

[[ $(screen -ls | grep -c -E 'PZ\s') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ -L -Logfile /tmp/PZ.log && \
screen -S PZ -X stuff "/home/pz1/Zomboid/start-server.sh -servername ININAME ^M"

[[ $(screen -ls | grep -c -E 'PZ-reader') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-reader -L -Logfile /tmp/PZ-reader.log && \
screen -S PZ-reader -X stuff "/opt/dizcord/reader.sh ^M"

[[ $(screen -ls | grep -c -E 'PZ-obit') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-obit && \
screen -S PZ-obit -p 0 -X stuff "/opt/dizcord/obit.sh ^M"

[[ $(screen -ls | grep -c -E 'PZ-bot') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-bot && \
screen -S PZ-bot -p 0 -X stuff "/usr/bin/node /opt/boidbot/bot.sh ^M"
