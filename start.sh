#!/bin/bash

URL='https://discord.com/api/webhooks/'
BLUE=45015

MESSAGE="**Rotting Domain** server reanimating now."

SRVRINI="rot"

date +%s > /tmp/srvr2-start.time
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$BLUE\", \"description\": \"$MESSAGE\" }] }" "$URL"

[[ $(screen -ls | grep -E 'PZ2\s' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2 -Logfile /tmp/PZ2.log && screen -S PZ2 -X stuff "/bin/bash /opt/pzserver2/start-server.sh -servername $SRVRINI ^M"

[[ $(screen -ls | grep -E 'PZ2-S-obit' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-obit-Logfile /tmp/PZ2-S-obit.log && screen -S PZ2-S-obit -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/obit.sh  ^M"
[[ $(screen -ls | grep -E 'PZ2-S-discon' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-discon -Logfile /tmp/PZ2-S-discon.log && screen -S PZ2-S-discon -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/discon.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-startup' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-startup -Logfile /tmp/PZ2-S-startup.log && screen -S PZ2-S-startup -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/startup.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-connect' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-connect -Logfile /tmp/PZ2-S-connect.log && screen -S PZ2-S-connect -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/connect.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-chopper' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-chopper -Logfile /tmp/PZ2-S-chopper.log && screen -S PZ2-S-chopper -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/chopper.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-shutdown' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-shutdown -Logfile /tmp/PZ2-S-shutdown.log && screen -S PZ2-S-shutdown -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/shutdown.sh ^M"
[[ $(screen -ls | grep -E 'PZ2-S-stream' | wc -l) -eq 0 ]] && screen -dm -s /bin/bash -S PZ2-S-stream -Logfile /tmp/PZ2-S-stream.log && screen -S PZ2-S-stream -p 0 -X stuff "/bin/bash /opt/pzserver2/dizcord/stream.sh ^M"
