#! /bin/bash

RED=16711680

# ADD YOUR DISCORD WEBHOOK URL TO THE NEXT LINE
URL='https://discord.com/api/webhooks/1132488373265760266/48oDcTn0Mup1jnZTpOctN0L--qqLOgfEA1_dlIikgvQyi1r5-mS-Jc9_-uF6MqJecvC0'

# Lets put in some funny death messages
# Credit where credit is due, I took inspiration from https://www.reddit.com/r/projectzomboid/comments/u3pivr/need_helpsuggestionswitty_comments/
RANDOS=('just died.' 'has now made ther contribution to the horde.' 'swapped sides.' 'has now completed their playthough.' 'used the wrong hole.' 'kicked the bucket.' 'decided to try something else (it did not work).' 'forgot to pay their tribute to the R-N-Geezus.' 'bought the farm.''is still walking... breathing... not so much' )

OBITUARY(){
if [[ $(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name "*user*" | tail -n1 | wc -l) ]];
then
USERFILE=$(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name "*user*" | tail -n1)
  tail -fn0 "$USERFILE" | \
  while read -r LINE ; do

    # We're gonna need a seed
    RANDOM=$$$(date +%s)

    DEADPLAYER=$(echo "$LINE" | grep -E -o '\S+\sdied' | awk '{print $1}')
    if [[ -n "$DEADPLAYER" ]];
    then
      MESSAGE1=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
      OBIT="_$(date +%H:%M):_ **$DEADPLAYER** $MESSAGE1"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"description\": \"$OBIT\" }] }" "$URL"
      DEADPLAYER=""
    fi

    # test if the VOYEUR file is still the current log file
    if [[ "$USERFILE" != $(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name "*user*" | tail -n1) ]];
    then
      break
    fi
  done
  OBITUARY
fi
}

VALIDATE(){
  [[ $(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name "*user*" | wc -l) -eq 0 ]] && PRESENT=0 || PRESENT=1

  if [[ $PRESENT -eq 0 ]]
  then
    sleep 1
    VALIDATE
  else
    OBITUARY
  fi

}

VALIDATE
