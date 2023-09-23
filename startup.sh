URL=''

LIME=65280

READER(){

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    STARTVAR="SERVER STARTED"
    SRVRUP=$(echo "$line" | grep -E -c "$STARTVAR")
    if [[ "$SRVRUP" -gt "0" ]];
    then
      # send timestamp to tmp file
      date +%s > /tmp/srvr2-up.time
      RISING=$(cat /tmp/srvr2-start.time)
      RISEN=$(cat /tmp/srvr2-up.time)
      RISESECS=$(( RISEN - RISING ))
      SRVRNAME=$(ps aux | grep 'servername' | grep -v grep | grep Project | awk '{print $NF}')
      touch /home/pzuser2/Zomboid/$SRVRNAME.up
      echo "$(date +%c) $SRVRNAME RISESECS" >> /home/pzuser2/Zomboid/$SRVRNAME.up

      if [[ $RISESECS -ge 60 ]];
      then
        RISETIME=$(printf '%dm %ds' $((RISESECS/60)) $((RISESECS%60)))
      else
        RISETIME=$(printf '%ds' $((RISESECS)))
      fi
      TITLE="Server is now **ONLINE**"
      MESSAGE="Server took $RISETIME to come online."
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$LIME\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL
      unset UPNOW
      break
    fi

  done

}

READER
