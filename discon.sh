#! /bin/bash


URL=''

RED=16711680

READER(){

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ###########################################################################
    ######  Disconnections
    ###########################################################################

    DISCONN=$(echo "$line" | grep -E '\[disconnect\]')

    if [[ -n $DISCONN ]];
    then
            DISCONNSTEAM=$(echo "$DISCONN" | grep -E -o 'steam-id=[0-9]*' | awk -F= '{print $2}')
            DISCONNPLAYER=$(echo "$DISCONN" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')

            if [[ -e /opt/pzserver2/dizcord/playerdb/$DISCONNSTEAM.online ]];
            then
                GAMESTART=$(cat /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".online)
              GAMEEND=$(date +%s)
              GAMETIME=$(( GAMEEND - GAMESTART ))
              echo $GAMETIME >> /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".total
              rm /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".online
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
            TOTAL=$(awk '{ sum += $1 } END { print sum }' /opt/pzserver2/dizcord/playerdb/"$DISCONNSTEAM".total)

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
     #\"fields\": [{ \"name\": \"Hours on Record:\", \"value\": \"$HRS\" }], \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      # do a lookup to get image name
      IMGNAME=$(grep -E "$DISCONNSTEAM" "/opt/pzserver2/dizcord/playerdb/users.log" | awk '{print $NF}')
      #curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER has disconnected\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\\nTotal time on this server: $LIFE\", \"thumbnail\": { \"url\": \"$IMGNAME\"} } }] }" $URL
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DISCONNPLAYER has disconnected:\", \"description\": \"$DISCONNPLAYER was online for $UPTIME\nTotal time on server: $LIFE\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
    fi

    ###### End of Disconnections

  done

}

READER
