URL='https://discord.com/api/webhooks/1132488373265760266/48oDcTn0Mup1jnZTpOctN0L--qqLOgfEA1_dlIikgvQyi1r5-mS-Jc9_-uF6MqJecvC0'

PINK=16761035
CRIMSON=14423100
RED=16711680
MAROON=8388608
BROWN=10824234
MISTYROSE=16770273
SALMON=16416882
CORAL=16744272
ORANGERED=16729344
CHOCOLATE=13789470
ORANGE=16753920
GOLD=16766720
IVORY=16777200
YELLOW=16776960
OLIVE=8421376
YELLOWGREEN=10145074
LAWNGREEN=8190976
CHARTREUSE=8388352
LIME=65280
GREEN=32768
SPRINGGREEN=65407
AQUAMARINE=8388564
TURQUOISE=4251856
AZURE=15794175
AQUACYAN=65535
TEAL=32896
LAVENDER=15132410
BLUE=255
DISCORDBLUE=45015
NAVY=128
BLUEVIOLET=9055202
INDIGO=4915330
DARKVIOLET=9699539
PLUM=14524637
MAGENTA=16711935
PURPLE=8388736
REDVIOLET=13047173
TAN=13808780
BEIGE=16119260
SLATEGRAY=7372944
SLATEGREY=7372944
DARKSLATEGRAY=3100495
DARKSLATEGREY=3100495
WHITE=16777215
WHITESMOKE=16119285
LIGHTGRAY=13882323
LIGHTGREY=13882323
SILVER=12632256
DARKGRAY=11119017
DARKGREY=11119017
GRAY=8421504
GREY=8421504
BLACK=0


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
