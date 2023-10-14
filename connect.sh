#! /bin/bash -x

# ADD YOUR DISCORD WEBHOOK TO THE NEXT LINE
URL='https://discord.com/api/webhooks/1132488373265760266/48oDcTn0Mup1jnZTpOctN0L--qqLOgfEA1_dlIikgvQyi1r5-mS-Jc9_-uF6MqJecvC0'

RED=16711680
PURPLE=8388736
WHITE=16777215

CONNSTEAM=""
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

}

JOIN(){

  echo $(date +%s) > /opt/pzserver2/dizcord/playerdb/"$CONNSTEAM".online

  STEAMLINK="https://steamcommunity.com/profiles/$CONNSTEAM"
  # get steam user page
  wget -O "/tmp/$CONNSTEAM" "$STEAMLINK"
  #get Steam Username
  STEAMNAME=$(grep -E '<title>' "/tmp/$CONNSTEAM" | awk '{print $4}' | rev | cut -c10- | rev)
  # get image extension
  # some profiles have backgrounds, if they do, then we need to modify the code to ignore them
  if [[ $(grep 'has_profile_background' "/tmp/$CONNSTEAM") ]]; then
    IMGEXT=$(grep -E -A4 'playerAvatarAutoSizeInner' "/tmp/$CONNSTEAM" | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
    # get the user image
    wget -O /opt/pzserver2/dizcord/playerdb/images/"$CONNSTEAM"."$IMGEXT" $(grep -A4 'playerAvatarAutoSizeInner' "/tmp/$CONNSTEAM" | tail -n1 | awk -F'"' '{print $2}')
    # get image link
    IMGNAME=$(cat /tmp/"$CONNSTEAM" | grep -A4 playerAvatarAutoSizeInner | tail -n1 | awk -F'"' '{print $2}')
  else
    IMGEXT=$(cat /tmp/"$CONNSTEAM" | grep -A1 playerAvatarAutoSizeInner | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
    # get the user image
    wget -O /opt/pzserver2/dizcord/playerdb/images/"$CONNSTEAM"."$IMGEXT" $(grep -A1 'playerAvatarAutoSizeInner' "/tmp/$CONNSTEAM" | tail -n1 | awk -F'"' '{print $2}')
    # get image link
    IMGNAME=$(cat /tmp/"$CONNSTEAM" | grep -A1 playerAvatarAutoSizeInner | tail -n1 | awk -F'"' '{print $2}')
  fi
    
  # get hours played
  HRS=$(cat /tmp/"$CONNSTEAM" | grep -B2 -E 'Project Zomboid' | grep -E 'on record' | grep -o -E '[0-9,]*')
  DATE=$(date +%Y-%m-%d\ %H:%M:%S)

  # Lets get other games from steam (NAME is game name LAST is last played, HRS is hours in that game)
  OGAMENAME1=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | grep -E "whiteLink" | head -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  OGAMENAME2=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | grep -E "whiteLink" | tail -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  OGAMELAST1=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| head -n1 | rev | cut -c9- | rev | sed 's/on/on:/' | sed 's/.*/\u&/' | xargs)
  OGAMELAST2=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| tail -n1 | rev | cut -c9- | rev | sed 's/on/on:/' | sed 's/.*/\u&/' | xargs)
  OGAMEHRS1=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | head -n1)
  OGAMEHRS2=$(grep -E -A4 "\"game_capsule\""  /tmp/$CONNSTEAM | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | tail -n1)

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
  if [[ $(grep -c -E "$CONNSTEAM" /opt/pzserver2/dizcord/playerdb/users.log) -eq 0 ]]; then
    echo -e "$DATE\t$CONNSTEAM\t$STEAMNAME\t$CONNIP\t$LOGINNAME\t$STEAMNAME.$IMGEXT\t$IMGNAME" >> /opt/pzserver2/dizcord/playerdb/users.log
    # format is:
    # FIRST SEEN            STEAMID                 STEAM NAME      IP ADDRESS      login   IMAGE NAME      IMAGE LINK
    # e.g.
    # 2023-08-21 16:25:21   76561198058880519       Blyzz.com       192.168.0.33    blyzz   Blyzz.com.gif
  fi

  if [[ -n $CONN_AUTH_DENIED ]]; then
    TITLE="Access Denied - Check your credentials."
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" $URL
    rm /opt/pzserver2/dizcord/playerdb/"$CONNSTEAM".online
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> /home/pzuser2/denied.log
  fi

}

READER(){

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    CONNSTEAM=$(echo "$line" | grep -E '\[fully-connected\]' | grep -E -o 'steam-id=[0-9]+' | awk -F= '{print $2}')
    CONNIP=$(echo "$line" | grep -E -o 'ip=[0-9.]*' | awk -F= '{print $2}')
    LOGINNAME=$(echo "$line" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')
    CONN_AUTH_DENIED=$(echo "$line" | grep -E -o 'Client sent invalid server password')

    if [[ -n $CONNSTEAM ]]; then
      if [[ -e /opt/pzserver2/dizcord/playerdb/"$CONNSTEAM".online ]]; then
        REJOIN
      else
        JOIN
      fi
    fi

  done

}

READER
