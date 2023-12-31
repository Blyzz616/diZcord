#!/bin/bash

URL='WEBHOOKPLACEHOLDER'
source /opt/dizcord/colours.dec

PLAYERS="Survivors still connected:"
DOWN="**HRNAME** server going down now."

touch /tmp/connected.players
touch /tmp/connected.num
echo "" > /tmp/connected.players
echo "" > /tmp/connected.num

KILL(){
  echo "running KILL"
  screen -S PZ-S-obit -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-discon -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-startup -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-connect -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-chopper -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-shutdown -p 0 -X stuff "^C exit ^M"
  screen -S PZ-S-stream -p 0 -X stuff "^C exit ^M"
}

TIMECALC () {
  #get timestamp from srvr-up.time
  TIMEUP=$(</opt/dizcord/times/ININAME.up)
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
TIMECALC
MESSAGE="The Server was up for $UPTIME"
DOWN="**HRNAME** server going down now."
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DOWN\", \"description\": \"$MESSAGE\" }] }" $URL

NOPLAYERS(){
  echo "NOPLAYERS :  $line"
  UPCALC
  KILL
  SRVDN
}

SOMEPLAYERS(){
  echo "SOMPLAYERS starting"
  screen -S PZ -p 0 -X stuff "players ^M"
  tail -Fn0 /home/USERPLACEHOLDER/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do
    echo "SOMPLAYERS : $line"
    if [[ "$line" = -* ]];
    then
      echo "$line" | cut -c2- >> /tmp/connected.players
      PLAYERNAMES=$(cat /tmp/connected.players | grep -v -E '^$')
      if [[ $CONNECTEDNUM -eq $(echo "$PLAYERNAMES" | wc -l) ]];
      then
#        SURVIVORS=$(echo $PLAYERNAMES | sed -i 's/$/\/n/g')
        UPCALC
        MESSAGE="The Server was up for $UPTIME"
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$DOWN\", \"description\": \"$MESSAGE\", \"fields\": [{ \"name\": \"Ejecting Survivors:\", \"value\": \"$PLAYERNAMES\" }] }] }" $URL
        for PLAYERS in $PLAYERNAMES
        do
          screen -S PZ -p 0 -X stuff "kickuser $PLAYERS -r \"The Server is going down now. Sorry.\" ^M"
        done
        KILL
          screen -S PZ -p 0 -X stuff "quit ^M"
        SRVDN
        break
      fi
    fi
  echo "SOMEPLAYERS OVER - server should be down"
  done

}



SRVDN(){
  tail -Fn0 /home/USERPLACEHOLDER/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do
    DISCONNSTEAM=$(echo "$line" | grep -E -o 'command-kick.*' | awk '{print $5}' | awk -F= '{print $2}')
    DISCONNPLAYER=$(echo "$line" | grep -E -o 'command-kick.*' | awk '{print $7}' | awk -F'"' '{print $2}')
    SRV=$(echo "$line" | grep -E -o 'SSteamSDK: LogOff')
    if [[ -n $KICKSTEAM ]];
    then
      if [[ -e /opt/dizcord/playerdb/$DISCONNSTEAM.online ]];
      then
        GAMESTART=$(cat /opt/dizcord/playerdb/"$DISCONNSTEAM".online)
        GAMEEND=$(date +%s)
        GAMETIME=$(( GAMEEND - GAMESTART ))
        echo $GAMETIME >> /opt/dizcord/playerdb/"$DISCONNSTEAM".total
        rm /opt/dizcord/playerdb/"$DISCONNSTEAM".online
      fi

      # Session Time
      if [[ $GAMETIME -ge 86400 ]];
      then
        UPTIME=$(printf '%dd %dh %dm %ds' $((GAMETIME/86400)) $((GAMETIME%86400/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
      elif [[ $GAMETIME -ge 3600  ]];
      then
        UPTIME=$(printf '%dh %dm %ds' $((GAMETIME/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
      elif [[ $GAMETIME -ge 60 ]];
      then
        UPTIME=$(printf '%dm %ds' $((GAMETIME/60)) $((GAMETIME%60)))
      else
        UPTIME=$(printf '%ds' $((GAMETIME)))
      fi

      # Total Time
      TOTAL=$(awk '{ sum += $1 } END { print sum }' /opt/dizcord/playerdb/"$DISCONNSTEAM".total)

      if [[ $TOTAL -ge 86400 ]];
      then
        LIFE=$(printf '%dd %dh %dm %ds' $((TOTAL/86400)) $((TOTAL%86400/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 3600  ]];
      then
        LIFE=$(printf '%dh %dm %ds' $((TOTAL/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 60 ]];
      then
        LIFE=$(printf '%dm %ds' $((TOTAL/60)) $((TOTAL%60)))
      else
        LIFE=$(printf '%ds' $((GAMETIME)))
      fi
      IMGNAME=$(grep -E "$DISCONNSTEAM" "/opt/dizcord/playerdb/users.log" | awk '{print $NF}')
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER has disconnected:\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\nTotal time on server: $LIFE\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
    fi
    if [[ -n  "$SRV" ]];
    then
      screen -S PZ -p 0 -X stuff "^C"
      sleep 2
      screen -S PZ -p 0 -X stuff "exit ^M"
    fi
  done
}

READER(){
  SENT
  tail -Fn0 /home/USERPLACEHOLDER/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do
    CONNECTEDNUM=$(echo "$line" | grep -E -o 'connected .[1-9]*' | awk -F"(" '{print $2}')
    echo "CONNECTEDNUM = $CONNECTEDNUM"
    echo "READER : $line"
    if [[ $CONNECTEDNUM -eq 0 ]];
    then
      NOPLAYERS
    else
      SOMEPLAYERS
    fi
  done
}

SENT(){
  echo "SENT"
  screen -S PZ -p 0 -X stuff "players ^M"
}

READER
