#!/bin/bash +x

URL='https://discord.com/api/webhooks/'
BLUE=45015

MESSAGE="**Rotting Domain** server reanimating now."

SRVRINI="rot"

date +%s > /tmp/srvr2-start.time
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" "$URL"

[[ $(screen -ls | grep -E 'PZ2\s' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2 && screen -S PZ2 -X stuff "/bin/bash /opt/pzserver2/start-server.sh -servername $SRVRINI ^M"
[[ $(screen -ls | grep -E 'PZ2-S-obit' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-obit && screen -S PZ2-S-obit -X stuff "/bin/bash /opt/pzserver2/dizcord/obit.sh  ^M"
[[ $(screen -ls | grep -E 'PZ2-S-discon' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-discon && screen -S PZ2-S-discon -X stuff "/bin/bash /opt/pzserver2/dizcord/discon.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-startup' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-startup && screen -S PZ2-S-startup -X stuff "/bin/bash /opt/pzserver2/dizcord/startup.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-connect' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-connect && screen -S PZ2-S-connect -X stuff "/bin/bash /opt/pzserver2/dizcord/connect.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-chopper' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-chopper && screen -S PZ2-S-chopper -X stuff "/bin/bash /opt/pzserver2/dizcord/chopper.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-shutdown' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-shutdown && screen -S PZ2-S-shutdown -X stuff "/bin/bash /opt/pzserver2/dizcord/shutdown.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-stream' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-stream && screen -S PZ2-S-stream -X stuff "/bin/bash /opt/pzserver2/dizcord/stream.sh ^M"
