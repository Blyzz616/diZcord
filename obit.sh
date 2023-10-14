#! /bin/bash

RED=16711680
OBITFILE=""

# ADD YOUR DISCORD WEBHOOK URL TO THE NEXT LINE
URL='https://discord.com/api/webhooks/'

# Lets put in some funny death messages
# Credit where credit is due, I took inspiration from https://www.reddit.com/r/projectzomboid/comments/u3pivr/need_helpsuggestionswitty_comments/
RANDOS=('just died.' 'has now made ther contribution to the horde.' 'swapped sides.' 'has now completed their playthough.' 'used the wrong hole.' 'kicked the bucket.' 'decided to try something else (it did not work).' 'forgot to pay their tribute to the R-N-Geezus.' 'bought the farm.''is still walking... breathing... not so much' )

OBITUARY(){
  tail -fn0 "$OBITFILE" | \
  while read -r LINE ; do

    # We're gonna need a seed
    RANDOM=$$$(date +%s)

    DEADPLAYER=$(echo "$LINE" | grep -E -o '\S+\sdied' | awk '{print $1}')
    if [[ -n "$DEADPLAYER" ]]; then
      MESSAGE=${RANDOS[ $RANDOM % ${#RANDOS[@]} ]}
      OBIT="**$DEADPLAYER** $MESSAGE"
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"description\": \"$OBIT\" }] }" "$URL"
    fi

    # test if the OBIT file is still the current log file
    if [[ "$OBITFILE" != $(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name "*user*" | tail -n1) ]]; then
      OBITFILE="$(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name '*user*')"
    fi
  done
}

VALIDATE(){
  OBITDIR="/home/pzuser2/Zomboid/Logs"
  OBITPATTERN="*user.txt"

  # Wait for a file to be created
  while true; do
    created_file=$(inotifywait -q -e create --format "%f" "$OBITDIR" | grep "$OBITPATTERN")
    if [[ -n $created_file ]]; then
      OBITFILE="$(find /home/pzuser2/Zomboid/Logs/ -maxdepth 1 -name '*user*')"
      break
    fi
    sleep 1
  done
  OBITUARY
}

VALIDATE
