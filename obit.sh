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
      STEAMID=$(echo "$DISCONN" | grep -E -o 'steam-id=[0-9]*' | awk -F= '{print $2}')
      # get player name
      DISCONNPLAYER=$(echo "$DISCONN" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')
      if [[ -e /opt/pzserver2/dizcord/playerdb/"$STEAMID".online ]]; then
        # if the player was online ? get the time  that the player was online and add it to the total for that player
        GAMESTART=$(cat /opt/pzserver2/dizcord/playerdb/"$STEAMID".online)
        GAMEEND=$(date +%s)
        GAMETIME=$(( GAMEEND - GAMESTART ))
        echo "$GAMETIME" >> /opt/pzserver2/dizcord/playerdb/"$STEAMID".total
        rm /opt/pzserver2/dizcord/playerdb/"$STEAMID".online
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
      TOTAL=$(awk '{ sum += $1 } END { print sum }' /opt/pzserver2/dizcord/playerdb/"$STEAMID".total)

      if [[ $TOTAL -ge 86400 ]]; then
        LIFE=$(printf '%dd %dh %dm %ds' $((TOTAL/86400)) $((TOTAL%86400/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 3600  ]]; then
        LIFE=$(printf '%dh %dm %ds' $((TOTAL/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
      elif [[ $TOTAL -ge 60 ]]; then
        LIFE=$(printf '%dm %ds' $((TOTAL/60)) $((TOTAL%60)))
      else
        LIFE=$(printf '%ds' $((GAMETIME)))
      fi

     HOURTIME=$(awk '{ sum += $1 } END { print sum }' /opt/pzserver2/dizcord/playerdb/"$STEAMID".total)
     if [[ $HOURTIME -ge 3600  ]]; then
        HOURS=$(printf '%d Hours' $((HOURTIME/3600)))
     fi

      # do a lookup to get image name
      IMGNAME=$(grep -E "$STEAMID" "/opt/pzserver2/dizcord/playerdb/users.log" | awk '{print $NF}')
      # if the player died in game and is now rage-quitting, let's shame the hell out of them.
      if [[ -e /tmp/"$STEAMID".dead ]]; then
        RANDOM=$$$(date +%s)
        RANDOS=("Looks like **$DISCONNPLAYER's** exit was more dramatic than their survival skills." \
                "Quitting is easy, surviving is hard. **$DISCONNPLAYER**, the zombies miss you." \
                "**$DISCONNPLAYER** decided to take a break from survival." \
                "The apocalypse is tough, but **$DISCONNPLAYER** might be tougher?. Don't let a setback keep you down. Rejoin and conquer!" \
                "Rage-quitting won't make the zombies go away, **$DISCONNPLAYER**. Come back and show them who's boss!" \
                "Surviving the apocalypse takes grit, **$DISCONNPLAYER**. Quitting only delays the inevitable. Ready for redemption?" \
                "Even the best stumble. **$DISCONNPLAYER**, the server needs your resilience. Rise from the ashes and reclaim your survival story!" \
                "Zombies: 1, **$DISCONNPLAYER**: 0. Are you going to let them have the last laugh? Get back in there and rewrite the ending!" \
                "Nobody said surviving the apocalypse was easy. **$DISCONNPLAYER**, dust off those setbacks and rejoin the fight!" \
                "Rage-quitting won't erase the past, **$DISCONNPLAYER**. Redemption is just a login away. The zombies are eagerly awaiting your return." \
                "Rage-quitting won't erase your past defeats, **$DISCONNPLAYER**. The apocalypse doesn't forgive, but it does offer second chances. Ready for yours?" \
                "Even the bravest survivors face setbacks. **$DISCONNPLAYER**, the world needs your resilience. Are you up for the challenge?" \
                "Quitting is easy, but survival is an art. **$DISCONNPLAYER**, your canvas awaits. Ready to paint a new masterpiece?" \
                "Rage-quitting is a temporary solution. **$DISCONNPLAYER**, the real challenge is staying and fighting. Ready to prove yourself?" \
                "The zombies might have won this round, but **$DISCONNPLAYER** isn't out for the count. Rejoin and turn the tables on the undead!" \
                "Apocalypse got you down, **$DISCONNPLAYER**? Quitting won't make it any easier. Rise from the ashes and show the zombies what you're made of!" \
                "Survival isn't for the faint-hearted. **$DISCONNPLAYER**, the server misses your resilience. Time to show the undead what you're truly capable of!" \
              )
        MESSAGE=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER Rage-quit\", \"description\": \"$MESSAGE\n\n$DISCONNPLAYER was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
        rm /tmp/"$STEAMID".dead
      else
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER has disconnected:\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      fi
    fi
  done
}

READER
