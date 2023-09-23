#!/bin/bash -x

URL='https://discord.com/api/webhooks/'
RED=16711680
ORANGE=16753920

# this file to limit the server-down notificaiton to 1
touch /tmp/dwn.cmd
echo "0" >/tmp/dwn.cmd

TIMECALC () {
  #get timestamp from srvr-up.time
  TIMEUP=$(</tmp/srvr2-up.time)
  #calculate up-time
  TIMEDOWN=$(date +%s)
  UPSECS=$(( TIMEDOWN - TIMEUP ))
  if [[ $UPSECS -ge 86400 ]];
  then
    UPTIME=$(printf '%dd %dh %dm %ds' $((UPSECS/86400)) $((UPSECS%86400/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 3600  ]];
  then
    UPTIME=$(printf '%dh %dm %ds' $((UPSECS/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 60 ]];
  then
    UPTIME=$(printf '%dm %ds' $((UPSECS/60)) $((UPSECS%60)))
  else
    UPTIME=$(printf '%ds' $((UPSECS)))
  fi
}

# This process warns players that the server will be going down in X minutes specified in the restart command
SHUTDOWNWARNING(){
  case "$1" in
    1)
    /opt/pzserver2/dizcord/onemin.sh &
    ;;

    2)
    /opt/pzserver2/dizcord/twomin.sh &
    ;;

    3)
    /opt/pzserver2/dizcord/threemin.sh &
    ;;

    4)
    /opt/pzserver2/dizcord/fourmin.sh &
    ;;

    5)
    /opt/pzserver2/dizcord/fivemin.sh &
    ;;

    *)
    ;;

  esac
  NOTICE="**Rotting Domain** server going down in ***$1 $MINUTE*** for maintenance."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"description\": \"$NOTICE\" }] }" "$URL"
}

# This funciton will initiate a shutdown process that posts the uptime to discord
SHUTDOWN(){
  TIMECALC
  MESSAGE="The Server was up for $UPTIME"
  DOWN="**Rotting Domain** server going down now."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DOWN\", \"description\": \"$MESSAGE\" }] }" $URL

  screen -S PZ2-S-obit -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-discon -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-startup -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-connect -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-chopper -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-shutdown -p 0 -X stuff "^C exit ^M"
  screen -S PZ2-S-stream -p 0 -X stuff "^C exit ^M"

  screen -S PZ2 -p 0 -X stuff "quit ^M"

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line;
  do
    DOWNSVR=$(echo "$line" | grep -c -E "SSteamSDK: LogOff")
    if [[ "$DOWNSVR" -eq 1 ]];
    then
      if [[ $(</tmp/dwn.cmd) -eq 0 ]];
      then
        echo "1" > /tmp/dwn.cmd
        screen -S PZ2 -p 0 -X stuff "^C exit ^M"
        /usr/local/bin/pzuser2/start.sh &
        exit
      else
        exit
      fi
    fi
  done
}

# This function will check for players, if there are none, it will immediately run the shutdown() funciton and kill the server
PLAYERCHECK(){
  screen -S PZ2 -p 0 -X stuff "players ^M"

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line;
  do
    EMPTY=$(echo "$line" | grep -o -E "Players connected \([0-9]" | awk -F"(" '{print $NF}')
    if [[ "$EMPTY" -ge 1 ]];
    then
      break # so break the loop (effectively do nothing and continue)
    elif [[ "$EMPTY" -eq 0 ]];
    then
      echo "No-one on server, Shutting down now to expedite matters"
      SHUTDOWN
    fi
  done
}

if [[ -z "$1" ]];
then
  RESTARTTIMER="5"
  MINUTE="MINUTES"
  PLAYERCHECK
  SHUTDOWNWARNING "$RESTARTTIMER"
  sleep 300
  SHUTDOWN
else
  case "$1" in
    now)
    SHUTDOWN
    ;;

    0)
    SHUTDOWN
    ;;

    1)
    MINUTE="MINUTE"
    ;;

    [2-5])
    MINUTE="MINUTES"
    ;;

    *)
    echo "Please pick a number between 0 and 5 and try again."
    exit
    ;;

  esac
fi

SHUTDOWNWARNING "$@"
sleep $((60*"$1"))
SHUTDOWN
