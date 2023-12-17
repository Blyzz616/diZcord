#! /bin/bash

screen -S PZ -p 0 -X stuff "servermsg \"Server going down in 4 minutes\" ^M"
sleep 5
# 5 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Server going down in 4 minutes\" ^M"
sleep 5
# 10 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Server going down in 4 minutes\" ^M"
sleep 5
# 15 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Server going down in 4 minutes\" ^M"
sleep 5
# 20 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Get to Safety.\" ^M"
sleep 5
# 25 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Get to Safety.\" ^M"
sleep 5
# 30 seconds
screen -S PZ -p 0 -X stuff "servermsg \"Get to Safety.\" ^M"
sleep 30
/opt/dizcord/threemin.sh
