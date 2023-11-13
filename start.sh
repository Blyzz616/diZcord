#!/bin/bash

URL='https://discord.com/api/webhooks/'
BLUE=45015

MESSAGE="**Blighted Dominion** server reanimating now."

SRVRINI="blight"

date +%s > "/opt/dizcord/times/$SRVRINI-start.time"
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" "$URL"

[[ $(screen -ls | grep -c -E 'PZ\s') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ -L -Logfile /tmp/PZ.log && \
screen -S PZ -X stuff "/home/pz1/Zomboid/start-server.sh -servername $SRVRINI ^M"

[[ $(screen -ls | grep -c -E 'PZ-reader') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-reader -L -Logfile /tmp/PZ-reader.log && \
screen -S PZ-reader -X stuff "/opt/dizcord/reader.sh ^M"

[[ $(screen -ls | grep -c -E 'PZ-obit') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-obit && \
screen -S PZ-obit -p 0 -X stuff "/opt/dizcord/obit.sh ^M"

[[ $(screen -ls | grep -c -E 'PZ-bot') -eq 0 ]] && \
screen -dm -s /bin/bash -S PZ-bot && \
screen -S PZ-obit -p 0 -X stuff "/usr/bin/node /opt/boidbot/bot.sh ^M"
