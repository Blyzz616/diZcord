#! /bin/bash

# ADD YOUR DISCORD WEBHOOK TO THE NEXT LINE
URL='https://discord.com/api/webhooks/1132488373265760266/48oDcTn0Mup1jnZTpOctN0L--qqLOgfEA1_dlIikgvQyi1r5-mS-Jc9_-uF6MqJecvC0'

RED=16711680
PURPLE=8388736
WHITE=16777215

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

  date +%s > /opt/pzserver2/dizcord/playerdb/"$CONNSTEAM".online

  if [[ -z "$OGAMENAME2" ]];
  then
    if [[ -z "$OGAMENAME1" ]];
    then
      if [[ -z $HRS ]];
      then
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
  if [[ $(grep -c -E "$CONNSTEAM" /opt/pzserver2/dizcord/playerdb/users.log) -eq 0 ]];
  then
    echo -e "$DATE\t$CONNSTEAM\t$STEAMNAME\t$CONNIP\t$LOGINNAME\t$STEAMNAME.$IMGEXT\t$IMGNAME" >> /opt/pzserver2/dizcord/playerdb/users.log
    # format is:
    # FIRST SEEN            STEAMID                 STEAM NAME      IP ADDRESS      login   IMAGE NAME      IMAGE LINK
    # e.g.
    # 2023-08-21 16:25:21   76561198058880519       Blyzz.com       192.168.0.33    blyzz   Blyzz.com.gif
  fi
  
  if [[ -n $CONN_AUTH_DENIED ]];
  then
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

    if [[ -n $CONNSTEAM ]];
    then
      if [[ -e /opt/pzserver2/dizcord/playerdb/"$CONNSTEAM".online ]];
      then
        REJOIN
      else
        JOIN
      fi
    fi

  done

}

READER
