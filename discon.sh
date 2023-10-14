#! /bin/bash

URL='https://discord.com/api/webhooks/'

RED=16711680
LAVENDER=15132410

READER(){

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    DISCONN=$(echo "$line" | grep -E '\[disconnect\]')

    if [[ -n $DISCONN ]]; then
      # we have a disconnection event
      # get steam id
      DISCONNSTEAM=$(echo "$DISCONN" | grep -E -o 'steam-id=[0-9]*' | awk -F= '{print $2}')
      # get player name
      DISCONNPLAYER=$(echo "$DISCONN" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')
      if [[ -e /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".online ]]; then
        # if the player was online ? get the time  that the player was online and add it to the total for that player
        GAMESTART=$(cat /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".online)
        GAMEEND=$(date +%s)
        GAMETIME=$(( GAMEEND - GAMESTART ))
        echo "$GAMETIME" >> /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".total
        rm /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".online
      fi

      # Session Time
      if [[ $GAMETIME -eq 0 ]]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$LAVENDER\", \"title\": \"The mods on the server appear to be out of date.\", \"description\": \"Restarting the server to update all mods.\nPlease wait a minute before rejoining.\" }] }" $URL
        /usr/local/bin/pzuser2/restart.sh &
        exit
      fi

      if [[ $GAMETIME -ge 86400 ]]; then
        UPTIME=$(printf '%dd %dh %dm %ds' $((GAMETIME/86400)) $((GAMETIME%86400/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
      elif [[ $GAMETIME -ge 3600  ]]; then
        UPTIME=$(printf '%dh %dm %ds' $((GAMETIME/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
      elif [[ $GAMETIME -ge 60 ]]; then
        UPTIME=$(printf '%dm %ds' $((GAMETIME/60)) $((GAMETIME%60)))
      else
        UPTIME=$(printf '%ds' $((GAMETIME)))
      fi

      # Total Time
      TOTAL=$(awk '{ sum += $1 } END { print sum }' /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".total)

      if [[ $TOTAL -ge 86400 ]]; then
        LIFE=$(printf '%dd %dh %dm %ds' $((TOTAL/86400)) $((TOTAL%86400/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 3600  ]]; then
        LIFE=$(printf '%dh %dm %ds' $((TOTAL/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 60 ]]; then
        LIFE=$(printf '%dm %ds' $((TOTAL/60)) $((TOTAL%60)))
      else
        LIFE=$(printf '%ds' $((GAMETIME)))
      fi

     HOURTIME=$(awk '{ sum += $1 } END { print sum }' /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".total)
     if [[ $HOURTIME -ge 3600  ]]; then
        HOURS=$(printf '%d Hours' $((HOURTIME/3600)))
     fi

      # do a lookup to get image name
      IMGNAME=$(grep -E "$DISCONNSTEAM" "/opt/pzserver2/dizcord/playerdb/users.log" | awk '{print $NF}')
      # if the player died in game and is now rage-quitting, let's shame the hell out of them.
      if [[ -e /tmp/"$DISCONNSTEAM".dead ]]; then
        RANDOM=$$$(date +%s)
        RANDOS=("just couldn't handle the heat" \
              "rage-quit" \
              "coulnd't handle the shame" \
              )
        MESSAGE=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER $MESSAGE\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
        rm /tmp/"$DISCONNSTEAM".dead
      else
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER has disconnected:\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      fi
    fi
  done
}

READER
