#! /bin/bash

# ADD YOUR DISCORD WEBHOOK TO THE NEXT LINE
URL='https://discord.com/api/webhooks/'

RED=16711680
PURPLE=8388736
WHITE=16777215

STEAMID=""
CONNIP=""
LOGINNAME=""
CONN_AUTH_DENIED=""

REJOIN(){
  # We're gonna need a seed
  RANDOM=$$$(date +%s)
  RAND_REJOIN=(\
    "Well, well, well, if it isn't **$LOGINNAME**. _Back_ from the dead." \
    "Player **$LOGINNAME** has rejoined the fight." \
    "**$LOGINNAME** decided to play for _Team Living_ once more." \
    "If life knocks **$LOGINNAME** down, they just get right back up" \
    "There's no keeping **$LOGINNAME** down for long." \
    "When life hands **$LOGINNAME** lemons, they do tequila shots." \
    "**$LOGINNAME** returns like a phoenix from the ashes of the apocalypse." \
    "Undead beware, **$LOGINNAME** is on a respawn rampage!" \
    "Zombies, meet your worst nightmare: **$LOGINNAME**, resurrected and ready for even more." \
    "Death is just a pit-stop for **$LOGINNAME** on the road of survival." \
    "Did someone say zombie buffet? **$LOGINNAME** is back for seconds." \
    "New day, new character, same old **$LOGINNAME** kicking zombie ass." \
    "They tried to bury **$LOGINNAME**. Little did they know, it's just a respawn point." \
    "Back in the land of the living: **$LOGINNAME**, the unstoppable survivor." \
  )
  TITLE="Respawn notice:"
  MESSAGE=${RAND_REJOIN[ $RANDOM % ${#RAND_REJOIN[@]} ]}
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$WHITE\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL
  rm /tmp/"$STEAMID".dead
}

JOIN(){

  date +%s > /opt/pzserver2/dizcord/playerdb/"$STEAMID".online

  STEAMLINK="https://steamcommunity.com/profiles/$STEAMID"
  # get steam user page
  wget -O "/tmp/$STEAMID" "$STEAMLINK"
  #get Steam Username
  STEAMNAME=$(grep -E '<title>' "/tmp/$STEAMID" | awk '{print $4}' | rev | cut -c10- | rev)
  # get image extension
  # some profiles have backgrounds, if they do, then we need to modify the code to ignore them
  if [[ $(grep 'has_profile_background' "/tmp/$STEAMID") ]]; then
    IMGEXT=$(grep -E -A4 'playerAvatarAutoSizeInner' "/tmp/$STEAMID" | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
    # get the user image
    wget -O /opt/pzserver2/dizcord/playerdb/images/"$STEAMID"."$IMGEXT" $(grep -A4 'playerAvatarAutoSizeInner' "/tmp/$STEAMID" | tail -n1 | awk -F'"' '{print $2}')
    # get image link
    IMGNAME=$(grep -A4 'playerAvatarAutoSizeInner' /tmp/"$STEAMID" | tail -n1 | awk -F'"' '{print $2}')
  else
    IMGEXT=$(grep -A1 'playerAvatarAutoSizeInner' /tmp/"$STEAMID" | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
    # get the user image
    wget -O /opt/pzserver2/dizcord/playerdb/images/"$STEAMID"."$IMGEXT" $(grep -A1 'playerAvatarAutoSizeInner' "/tmp/$STEAMID" | tail -n1 | awk -F'"' '{print $2}')
    # get image link
    IMGNAME=$(grep -A1 'playerAvatarAutoSizeInner' /tmp/"$STEAMID" | tail -n1 | awk -F'"' '{print $2}')
  fi
    
  # get hours played
  HRS=$(grep -B2 -E 'Project Zomboid' /tmp/"$STEAMID" | grep -E 'on record' | grep -o -E '[0-9,]*')
  DATE=$(date +%Y-%m-%d\ %H:%M:%S)

  # Lets get other games from steam (NAME is game name LAST is last played, HRS is hours in that game)
  OGAMENAME1=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | grep -E "whiteLink" | head -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  OGAMENAME2=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | grep -E "whiteLink" | tail -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  OGAMELAST1=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| head -n1 | rev | cut -c9- | rev | sed 's/on/on:/' | sed 's/.*/\u&/' | xargs)
  OGAMELAST2=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| tail -n1 | rev | cut -c9- | rev | sed 's/on/on:/' | sed 's/.*/\u&/' | xargs)
  OGAMEHRS1=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | head -n1)
  OGAMEHRS2=$(grep -E -A4 "\"game_capsule\""  /tmp/"$STEAMID" | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | tail -n1)

  # lets keep a record of who joins the server
  touch /opt/pzserver2/dizcord/playerdb/users.log /opt/pzserver2/dizcord/playerdb/access.log /opt/pzserver2/dizcord/playerdb/denied.log
  echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) attempted connection" >> /opt/pzserver2/dizcord/playerdb/access.log

  if [[ -z "$OGAMENAME2" ]]; then
    if [[ -z "$OGAMENAME1" ]]; then
      if [[ -z $HRS ]]; then
        curl -H "Content-Type: application/json" -X POST -d \
        "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\", \
        \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      else
        curl -H "Content-Type: application/json" -X POST -d \
        "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\", \
        \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
        \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      fi
    else
      curl -H "Content-Type: application/json" -X POST -d \
      "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\", \
      \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
      { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": false }, \
      { \"name\": \"$STEAMNAME has also played:\", \"value\": \"\", \"inline\": false }, \
      { \"name\": \"$OGAMENAME1\", \"value\": \"$OGAMEHRS1 \n $OGAMELAST1\", \"inline\": true  }, \
      \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
    fi
  else
    curl -H "Content-Type: application/json" -X POST -d \
    "{\"embeds\": [{ \"color\": \"$PURPLE\",  \"title\": \"New connection:\",  \"description\": \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\",  \
    \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
    { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": false }, \
    { \"name\": \"$STEAMNAME has also played:\", \"value\": \"\", \"inline\": false }, \
    { \"name\": \"$OGAMENAME1\", \"value\": \"$OGAMEHRS1 \n $OGAMELAST1\", \"inline\": true  }, \
    { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": true }, \
    { \"name\": \"$OGAMENAME2\", \"value\": \"$OGAMEHRS2 \n $OGAMELAST2\", \"inline\": true }],  \
    \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
  fi

  # check to see if we have a record of the user, if not, add to users.log and save image.
  if [[ $(grep -c -E "$STEAMID" /opt/pzserver2/dizcord/playerdb/users.log) -eq 0 ]]; then
    echo -e "$DATE\t$STEAMID\t$STEAMNAME\t$CONNIP\t$LOGINNAME\t$STEAMNAME.$IMGEXT\t$IMGNAME" >> /opt/pzserver2/dizcord/playerdb/users.log
    # format is:
    # FIRST SEEN            STEAMID                 STEAM NAME      IP ADDRESS      login   IMAGE NAME      IMAGE LINK
    # e.g.
    # 2023-08-21 16:25:21   76561198058880519       Blyzz.com       192.168.0.33    blyzz   Blyzz.com.gif
    # If they're not in the users log, they're not in the alias log - add that too
    echo -e "$STEAMID\t$LOGINNAME" >> /opt/pzserver2/dizcord/playerdb/alias.log
  else
    if [[ $(grep -c -E "$LOGINNAME" /opt/pzserver2/dizcord/playerdb/alias.log) -eq 0 ]]; then
    # Ok, so we've got a record of the user in users.log, but no alternate aliases in alias.log so lets save the new username
    # format is:
    # STEAMID                 FIRST           OTHERS
    # e.g.
    # 76561198058880519       Blyzz           blyzz-test        blyzz-2
    sed -i -E "/^$STEAMID/ s/$/\t$LOGINNAME/" /opt/pzserver2/dizcord/playerdb/alias.log
    fi
  fi

  if [[ -n $CONN_AUTH_DENIED ]]; then
    TITLE="Access Denied - Check your credentials."
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" $URL
    rm /opt/pzserver2/dizcord/playerdb/"$STEAMID".online
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> /home/pzuser2/denied.log
  fi

}

READER(){
  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do
    STEAMID=$(echo "$line" | grep -E '\[fully-connected\]' | grep -E -o 'steam-id=[0-9]+' | awk -F= '{print $2}')
    CONNIP=$(echo "$line" | grep -E -o 'ip=[0-9.]*' | awk -F= '{print $2}')
    LOGINNAME=$(echo "$line" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')
    CONN_AUTH_DENIED=$(echo "$line" | grep -E -o 'Client sent invalid server password')
    if [[ -n $STEAMID ]]; then
      if [[ -e /opt/pzserver2/dizcord/playerdb/"$STEAMID".online ]]; then
        REJOIN
      else
        JOIN
      fi
    fi
  done
}

READER
