#! /bin/bash

screen -S PZ2 -p 0 -X stuff "servermsg \"Server going down in 2 minutes\" ^M"
sleep 5
# 5 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"Server going down in 2 minutes\" ^M"
sleep 5
# 10 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"Server going down in 2 minutes\" ^M"
sleep 5
# 15 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"Server going down in 2 minutes\" ^M"
sleep 5
# 20 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"You better get to safety if you're not already there.\" ^M"
sleep 5
# 25 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"You better get to safety if you're not already there.\" ^M"
sleep 5
# 30 seconds
screen -S PZ2 -p 0 -X stuff "servermsg \"You better get to safety if you're not already there.\" ^M"
sleep 30
/opt/dizcord/onemin.sh
