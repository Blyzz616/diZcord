#!/bin/bash

URL='https://discord.com/api/webhooks/'
RED=16711680
ORANGE=16753920

# this file to limit the server-down notificaiton to 1
touch /tmp/dwn.cmd
echo "0" > /tmp/dwn.cmd

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
    MINUTE="MINUTE"
    /opt/pzserver2/dizcord/onemin.sh &
    ;;

    2)
    MINUTE="MINUTES"
    /opt/pzserver2/dizcord/twomin.sh &
    ;;

    3)
    MINUTE="MINUTES"
    /opt/pzserver2/dizcord/threemin.sh &
    ;;

    4)
    MINUTE="MINUTES"
    /opt/pzserver2/dizcord/fourmin.sh &
    ;;

    5)
    MINUTE="MINUTES"
    /opt/pzserver2/dizcord/fivemin.sh &
    ;;

    *)
    echo "Incorrect time variable passed to SHUTDOWNWARNING Function" > /tmp/dizcord.err
    ;;
  esac

  NOTICE="**Rotting Domain** server going down in ***$1 $MINUTE*** for maintenance."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"description\": \"$NOTICE\" }] }" "$URL"

  sleep $((60*"$1"))
  SHUTDOWN
}

# This funciton will initiate a shutdown process that posts the uptime to discord
SHUTDOWN(){
  TIMECALC
  MESSAGE="The Server was up for $UPTIME"
  DOWN="**Rotting Domain** server going down now."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DOWN\", \"description\": \"$MESSAGE\" }] }" $URL

  screen -S PZ2-S-obit -X stuff "^C"
  screen -S PZ2-S-discon -X stuff "^C"
  screen -S PZ2-S-connect -X stuff "^C"
  screen -S PZ2-S-chopper -X stuff "^C"
  screen -S PZ2-S-shutdown -X stuff "^C"
  screen -S PZ2-S-stream -X stuff "^C"
  sleep 2
  screen -S PZ2-S-obit -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-obit.log ]] && rm /tmp/PZ2-S-obit.log
  screen -S PZ2-S-discon -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-discon.log ]] && rm /tmp/PZ2-S-discon.log
  screen -S PZ2-S-connect -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-connect.log ]] && rm /tmp/PZ2-S-connect.log
  screen -S PZ2-S-chopper -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-chopper.log ]] && rm /tmp/PZ2-S-chopper.log
  screen -S PZ2-S-shutdown -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-shutdown.log ]] && rm /tmp/PZ2-S-shutdown.log
  screen -S PZ2-S-stream -X stuff "exit ^M"; [[ -e /tmp/PZ2-S-stream.log ]] && rm /tmp/PZ2-S-stream.log


  if [[ "$EMPTY" -gt "0" ]];
  then
    CONNECTED=()
    # Ok, let's kick these lazy buggers out
    screen -S PZ2 -X stuff "players ^M"

    if [[ $(grep -c "command not found" /tmp/PZ2.log) -gt 0 ]];
    then
      screen -S PZ2 -X stuff "exit^M"; rm /tmp/PZ2.log
    else
      tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
      while read -r line;
      do
        if [[ -z "$line" ]]
        then
          for element in "${CONNECTED[@]}"; do
            screen -S PZ2 -X stuff "kickuser \"$element\" -r \"You were warned\" ^M"
          done
          break
        else
          PLAYER=$(echo "$line" | cut -c2-)
          CONNECTED+=("$PLAYER")
        fi
      done
    fi
  else
    tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
    while read -r line;
    do
      DOWNSVR=$(echo "$line" | grep -c -E "SSteamSDK: LogOff")
      if [[ "$DOWNSVR" -eq 1 ]];
      then
        if [[ $(</tmp/dwn.cmd) -eq 0 ]];
        then
          echo "1" > /tmp/dwn.cmd
          screen -S PZ2 -X stuff "^C"
          sleep 2
          screen -S PZ2 -X stuff "exit ^M"
          /usr/local/bin/pzuser2/start.sh &
          break
        fi
      fi
    done
  fi
  exit
}

# This function will check for players, if there are none, it will immediately run the shutdown() funciton and kill the server
PLAYERCHECK(){
  screen -S PZ2 -X stuff "players ^M"

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line;
  do
    EMPTY=$(echo "$line" | grep -o -E "Players connected \([0-9]" | awk -F"(" '{print $NF}')
    if [[ "$EMPTY" -ge 1 ]];
    then
      SHUTDOWNWARNING "$RESTARTTIMER"
      break
    elif [[ "$EMPTY" -eq 0 ]];
    then
      NOTICE="No-one on **Rotting Domain** right now, skipping warnings."
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"description\": \"$NOTICE\" }] }" "$URL"
      SHUTDOWN
    fi
  done
}

if [[ -z "$1" ]];
then
  RESTARTTIMER="5"
  PLAYERCHECK
else
  RESTARTTIMER="$1"
  case "$1" in
    now)
    SHUTDOWN
    ;;

    0)
    SHUTDOWN
    ;;

    [1-5])
    PLAYERCHECK
    ;;

    *)
    echo "Please pick a number between 0 and 5 and try again."
    exit
    ;;
  esac
fi
