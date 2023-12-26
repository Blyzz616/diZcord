#! /bin/bash

# The all-important webhook!
URL='WEBHOOKPLACEHOLDER'

# File containing all the colours we use in discord
source /opt/dizcord/colours.dec

# We're gonna need a lot off files to be present:
touch /home/USERPLACEHOLDER/crash.true

# Set global variable soth at it's available to all funcitons
LINE=""

# A lot of this stuff used in multiple funcitons
SRVRUP=""
RANDOM=""
STEAMID=""
CONNIP=""
LOGINNAME=""
STEAMNAME=""
CHOP_ACTIVE=""
CHOP_ARRIVE=""
CHOP_SEARCH=""
CHOP_LEAVE=""
EHE_LAUNCH=""
EHE_TARGET=""
EHE_CRASH=""
EHE_CRASH_LOG=""
EHE_ROAMING=""
EHE_FLY_OVER=""
EHE_GO_HOME=""
EHE_CLASS=""
DISCONN=""
DEADPLAYER=""

# This should only run once, when the SCRIPT is started (before the server comes online)
date +%s > /opt/dizcord/times/ININAME.up

# We're gonna need a seed for almost everything... and we're gonna be calling it quite a bit so here it is:
SEED(){
  RANDOM=$$$(date +%s)
}

# function to do all the heli event and expanded helicopter event (EHE) stuff
CHOPPER(){
  # EHE handling
  EHE_TYPE="/opt/dizcord/ehe.type"

  TITLE="Helicopter Event"

  # Lets set some arrays
  RAND_ACTIVE=(\
    "What was that?" \
    "Did you hear something" \
    "What was that sound?" \
    "Do you hear something?" \
    "Uhm, I think we might have a problem..." \
    "Shh shh shh shh, listen..." \
    "Wait, QUIEIT! I think I hear something" \
  )
  RAND_ARRIVE=(\
    "Is that a helicopter?" \
    "Kinda sounds like a motorbike." \
    "Whoa! Is that Search and Rescue?" \
    "Is is a bird? A plane? Nope...  just a chopper" \
  )
  RAND_SEARCH=(\
    "Why is it flying back and forth like that?" \
    "I think it might be looking for us!." \
    "I think that he is flying a search pattern" \
    "If he keeps flying around like that he'll bring down a horde on us!" \
  )
  RAND_LEAVE=(\
    "Wait... Why is he leaving?" \
    "Phew, he's leaving, I think we may be safe now." \
    "Yeah, thats right, fly away and don't come back!" \
    "I think we're truly alone now." \
    "I think were safe. For the time being." \
  )
  RAND_EHE_TARGET=(\
    "Uhm **$EHE_TARGET**, I think you might want to get ready?" \
    "**$EHE_TARGET**, you might want to think about arming yourself." \
    "I think he saw you **$EHE_TERGET!**. RUN!" \
  )
  RAND_EHE_CRASH=(\
    "Whoa! Did you see that?" \
    "I think somthing... Hit? It??" \
    "Was that an explosion?" \
    "Is it on fire?" \
    "Hey Hey Hey!, I think he may be in trouble! " \
    "What the hell?" \
    "Oh. My. God! I think he's going down!" \
  )
  SURVIVOR_SMALLPLANE=(\
    "Why is it flying back and forth like that?" \
    "I think it might be looking for us!." \
    "I think that he is flying a search pattern" \
    "If he keeps flying around like that he'll bring down a horde on us!" \
  )
  RAIDERS=(\
    "What the hell was that?" \
    "WHAT. IS. HE. DOING" \
    "WHY IS HE PLAYING THAT AWFUL MUSIC?" \
    "Why? Why? Why do this to us?" \
    "What is this guy's problem" \
    "Who **IS** that? What did we ever do to him?" \
    "OMG! He's gonna bring the whole horde down on us! Get Ready!" \
  )
  SURVIVOR_HELI=(\
    "Why is it flying back and forth like that?" \
    "I think it might be looking for us!." \
    "I think that he is flying a search pattern" \
    "If he keeps flying around like that he will bring down a horde on us!" \
        )
  RAND_EHE_FLYOVER=(\
    "Whoa! I think he flew RIGHT over you there **$EHE_FLY_OVER**" \
    "Wow! Was he aiming fore you **$EHE_FLY_OVER**?" \
  )
  RAND_EHE_LEAVE=(\
    "Wait... Why is he leaving?" \
    "Phew, he's leaving, I think we may be safe now." \
    "I think we are truly alone now" \
  )

  if [[ -n $CHOP_ACTIVE ]]; then
    SEED
    MESS_ACTIVE=${RAND_ACTIVE[ $RANDOM % ${#RAND_ACTIVE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
  fi

  if [[ -n $CHOP_ARRIVE ]]; then
    SEED
    MESS_ARRIVE=${RAND_ARRIVE[ $RANDOM % ${#RAND_ARRIVE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ARRIVE\" }] }" $URL
  fi

  if [[ -n $CHOP_SEARCH ]]; then
    SEED
    MESS_SEARCH=${RAND_SEARCH[ $RANDOM % ${#RAND_SEARCH[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
  fi

  if [[ -n $CHOP_LEAVE ]]; then
    SEED
    MESS_LEAVE=${RAND_LEAVE[ $RANDOM % ${#RAND_LEAVE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" $URL
  fi

  ###########
  ##  EHE  ##
  ###########

  if [[ -n "$EHE_LAUNCH"  ]]; then
    touch "$EHE_TYPE"
    echo "$EHE_LAUNCH" > "$EHE_TYPE"
    SEED
    MESS_ACTIVE=${RAND_ACTIVE[ $RANDOM % ${#RAND_ACTIVE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
  fi

  if [[ -n "$EHE_TARGET" ]]; then
    if ! [[ "$EHE_TARGET" =~ [0-9]+,\s[0-9]+ ]]; then
      SEED
      MESS_ACTIVE=${RAND_EHE_TARGET[ $RANDOM % ${#RAND_EHE_TARGET[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
    fi
  fi

  if [[ "$EHE_CRASH" = "true" ]]; then
    touch /opt/dizcord/crash.true
    echo "true" > "/opt/dizcord/crash.true"
    SEED
    MESS_ACTIVE=${RAND_EHE_CRASH[ $RANDOM % ${#RAND_EHE_CRASH[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
  fi

  if [[ -n "$EHE_CRASH_LOG" ]]; then
    if [[ $(cat /opt/dizcord/crash.true) = "true" ]]; then
      touch /opt/dizcord/crash.log
      tail -n20 /home/USERPLACEHOLDER/Zomboid/server-console.txt | grep -B10 -A10 -E "crashing:true" > /home/USERPLACEHOLDER/crash.log
    fi
  fi

  if [[ -n "$EHE_CLASS" ]]; then
    TITLE="Chopper type"
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"||$EHE_CLASS||\" }] }" $URL
  fi

  if [[ -n "$EHE_ROAMING" ]]; then
    case $EHE_TYPE in

      survivor_smallplane)
        SEED
        MESS_ROAM=${SURVIVOR_SMALLPLANE[ $RANDOM % ${#SURVIVOR_SMALLPLANE[@]} ]}
        ;;

      raiders)
        SEED
        MESS_ROAM=${RAIDERS[ $RANDOM % ${#RAIDERS[@]} ]}
        ;;

      survivor_heli)
        SEED
        MESS_ROAM=${SURVIVOR_HELI[ $RANDOM % ${#SURVIVOR_HELI[@]} ]}
        ;;

      *)
        MESS_ROAM="New EHE event- check /home/USERPLACEHOLDER/newEHE.log"
        touch /home/USERPLACEHOLDER/newEHE.log
        tail -n20 /home/USERPLACEHOLDER/Zomboid/server-console.txt | grep -B10 -A10 -E 'SCHEDULED-LAUNCH.*id:[a-z_]*' >> /home/USERPLACEHOLDER/newEHE.log
        ;;
    esac
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_ROAM\" }] }" $URL
  fi

  if [[ -n "$EHE_FLY_OVER" ]]; then
    SEED
    MESS_SEARCH=${RAND_EHE_FLYOVER[ $RANDOM % ${#RAND_EHE_FLYOVER[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
  fi

  if [[ -n "$EHE_GO_HOME" ]]; then
    SEED
    MESS_LEAVE=${RAND_EHE_LEAVE[ $RANDOM % ${#RAND_EHE_LEAVE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" $URL
  fi
}

DENIED(){
  TITLE="Access Denied - Check your credentials."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" $URL
  rm /opt/dizcord/playerdb/"$STEAMID".online
  echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> /opt/dizcord/playerdb/denied.log
}

REJOIN(){
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
  SEED
  MESSAGE=${RAND_REJOIN[ $RANDOM % ${#RAND_REJOIN[@]} ]}
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DARKVIOLET\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL
  rm /tmp/"$STEAMID".dead
}

JOIN(){
  today=
  touch /opt/dizcord/times/"$STEAMID".online
  date +%s > /opt/dizcord/times/"$STEAMID".online

  if [[ -n "$CONNIP" ]]; then
    MS=$(ping -c 4 "$CONNIP" | grep -oP "(?<=time=)\d+(\.\d+)?(?= ms)" | awk '{sum+=$1} END {print sum/NR}' | awk -F"." '{print $1}')
    if [[ ! -f /opt/dizocrd/playerdb/"$STEAMID".about ]]; then
      curl -sL http://ip-api.com/json/"$CONNIP"?fields=36757983 > /opt/dizcord/playerdb/"$STEAMID".about
    else
      if [[ $(cat /opt/dizcord/playerdb/"$STEAMID".about | jq -r '.status') = "fail" ]]; then
        curl -sL http://ip-api.com/json/"$CONNIP"?fields=36757983 > /opt/dizcord/playerdb/"$STEAMID".about
    fi
  fi

  STEAMLINK="https://steamcommunity.com/profiles/$STEAMID"
  if [[ $(grep -c "$STEAMID" /opt/dizcord/playerdb/users.log) -gt 0 ]]; then
    #use local info to reduce unnecessary net lookups
    STEAMNAME=$(grep -E "$STEAMID" /opt/dizcord/playerdb/users.log | awk -F"\t" '{print $3}')
    IMGNAME=$(grep -E "$STEAMID" /opt/dizcord/playerdb/users.log | awk '{print $NF}')
  else
    wget -O /opt/dizcord/playerdb/html/"$STEAMID".html "$STEAMLINK"
    #get Steam Username
    STEAMNAME=$(grep -E '<title>' /opt/dizcord/playerdb/html/"$STEAMID".html | awk -F":" '{print $3}' | xargs | awk -F"<" '{print $1}')
    # get image extension
    # some profiles have backgrounds, if they do, then we need to modify the code to ignore them
    if grep -q 'has_profile_background' /opt/dizcord/playerdb/html/"$STEAMID".html; then
      IMGEXT=$(grep -E -A4 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
      # get the user image
      wget -O /opt/dizcord/playerdb/images/"$STEAMID"."$IMGEXT" $(grep -A4 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}')
      # get image link
      IMGNAME=$(grep -A4 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}')
    else
      IMGEXT=$(grep -A1 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}' | awk -F. '{print $NF}')
      # get the user image
      wget -O /opt/dizcord/playerdb/images/"$STEAMID"."$IMGEXT" $(grep -A1 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}')
      # get image link
      IMGNAME=$(grep -A1 'playerAvatarAutoSizeInner' /opt/dizcord/playerdb/html/"$STEAMID".html | tail -n1 | awk -F'"' '{print $2}')
    fi
    cp /opt/dizcord/playerdb/images/"$STEAMID"."$IMGEXT" /opt/dizcord/playerdb/images/"$STEAMNAME"."$IMGEXT"
  fi

  # get hours played
  HRS=$(grep -B2 -E 'Project Zomboid' /opt/dizcord/playerdb/html/"$STEAMID".html | grep -E 'on record' | grep -o -E '[0-9,]*')
  DATE=$(date +%Y-%m-%d\ %H:%M:%S)

  # Lets get other games from steam (NAME is game name LAST is last played, HRS is hours in that game)
  OGAMENAME1=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | grep -E "whiteLink" | head -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  OGAMENAME2=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | grep -E "whiteLink" | tail -n1 | xargs | sed 's/.*app\/[0-9]*>//'  | rev | cut -c12- | rev)
  if [[ $(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| head -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs | awk '{print $3 " " $4}') = $(date +%d" "%b) ]]; then
    OGAMELAST1="Last played: Today"
  elif [[ $(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| head -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs | awk '{print $3 " " $4}') = $(date -d "yesterday" +%d" "%b) ]]; then
    OGAMELAST1="Last played: Yesterday"
  else
    OGAMELAST1=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| head -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs)
  fi
  if [[ $(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| tail -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs) = $(date +%d" "%b) ]]; then
    OGAMELAST2="Last played: Today"
  elif [[ $(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| tail -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs) = $(date -d "yesterday" +%d" "%b) ]]; then
    OGAMELAST2="Last played: Yesterday"
  else
    OGAMELAST2=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E 'last.*'| tail -n1 | rev | cut -c9- | rev | sed 's/ on/:/' | sed 's/.*/\u&/' | xargs)
  fi
  OGAMEHRS1=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | head -n1)
  OGAMEHRS2=$(grep -E -A4 "\"game_capsule\""  /opt/dizcord/playerdb/html/"$STEAMID".html | grep -v 108600 | sed 's/^\s*//' | tail -n10 | grep -o -E '.*ord' | tail -n1)

  # lets keep a record of who joins the server
  touch /opt/dizcord/playerdb/users.log /opt/dizcord/playerdb/access.log /opt/dizcord/playerdb/denied.log
  
  if [[ $(wc -l /opt/dizcord/playerdb/users.log) -eq 0 ]]; then
    echo -e 'FIRST SEEN\tSTEAMID\tSTEAM-NAME\tIP ADDRESS\tlogin\tIMAGE NAME\tIMAGE LINK' > /opt/dizcord/playerdb/users.log
  fi  
  
  echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) attempted connection" >> /opt/dizcord/playerdb/access.log
  
  if [[ -z "$OGAMENAME2" ]]; then
    if [[ -z "$OGAMENAME1" ]]; then
      if [[ -z $HRS ]]; then
        curl -H "Content-Type: application/json" -X POST -d \
        "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \
        \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\n From IP: $CONNIP" with ping: $MS\",  \
        \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      else
        curl -H "Content-Type: application/json" -X POST -d \
        "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \
        \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\n From IP: $CONNIP" with ping: $MS\",  \
        \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
        \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
      fi
    else
      curl -H "Content-Type: application/json" -X POST -d \
      "{\"embeds\": [{ \"color\": \"$PURPLE\", \"title\": \"New connection:\",  \"description\": \
      \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\n From IP: $CONNIP" with ping: $MS\",  \
      \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
      { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": false }, \
      { \"name\": \"$STEAMNAME has also played:\", \"value\": \"\", \"inline\": false }, \
      { \"name\": \"$OGAMENAME1\", \"value\": \"$OGAMEHRS1 \n $OGAMELAST1\", \"inline\": true  }, \
      \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
    fi
  else
    curl -H "Content-Type: application/json" -X POST -d \
    "{\"embeds\": [{ \"color\": \"$PURPLE\",  \"title\": \"New connection:\",  \"description\": \
    \"Steam Profile: [$STEAMNAME]($STEAMLINK)\nLogging in as **$LOGINNAME**\n From IP: $CONNIP" with ping: $MS\",  \
    \"fields\": [ { \"name\": \"Hours on Record:\", \"value\": \"$HRS\", \"inline\": false }, \
    { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": false }, \
    { \"name\": \"$STEAMNAME has also played:\", \"value\": \"\", \"inline\": false }, \
    { \"name\": \"$OGAMENAME1\", \"value\": \"$OGAMEHRS1 \n $OGAMELAST1\", \"inline\": true  }, \
    { \"name\": \"\u200b\", \"value\": \"\u200b\", \"inline\": true }, \
    { \"name\": \"$OGAMENAME2\", \"value\": \"$OGAMEHRS2 \n $OGAMELAST2\", \"inline\": true }],  \
    \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
  fi

  # check to see if we have a record of the user, if not, add to users.log and save image.
  if [[ $(grep -c -E "$STEAMID" /opt/dizcord/playerdb/users.log) -eq 0 ]]; then
    echo -e "$DATE\t$STEAMID\t$STEAMNAME\t$CONNIP\t$LOGINNAME\t$STEAMNAME.$IMGEXT\t$IMGNAME" >> /opt/dizcord/playerdb/users.log
    # format is:
    # FIRST SEEN            STEAMID                 STEAM NAME      IP ADDRESS      login   IMAGE NAME      IMAGE LINK
    # e.g.
    # 2023-08-21 16:25:21   76561198058880519       Blyzz.com       192.168.0.33    blyzz   Blyzz.com.gif
    # If they're not in the users log, they're not in the alias log - add that too
    echo -e "$STEAMID\t$LOGINNAME" >> /opt/dizcord/playerdb/alias.log
  else
    if [[ $(grep -c -E "$LOGINNAME" /opt/dizcord/playerdb/alias.log) -eq 0 ]]; then
      # Ok, so we've got a record of the user in users.log, but no alternate aliases in alias.log so lets save the new username
      # format is:
      # STEAMID                 FIRST           OTHERS
      # e.g.
      # 76561198058880519       Blyzz           blyzz-test        blyzz-2
      sed -i -E "/^$STEAMID/ s/$/\t$LOGINNAME/" /opt/dizcord/playerdb/alias.log
    fi
  fi

  if [[ -n $CONN_AUTH_DENIED ]]; then
    TITLE="Access Denied - Check your credentials."
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\" }] }" $URL
    rm /opt/dizcord/playerdb/"$STEAMID".online
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Steam user $STEAMNAME ($STEAMLINK) was denied connection" >> /opt/dizcord/playerdb/denied.log
  fi
}

DISCON(){
  STEAMID=$(echo "$DISCONN" | grep -E -o 'steam-id=[0-9]*' | awk -F= '{print $2}')
  STEAMNAME=$(grep "$STEAMID" /opt/dizcord/playerdb/users.log | awk -F"\t" '{print $3}')
  STEAMLINK=$("https://steamcommunity.com/profiles/$STEAMID")

  # If the player was online - write play times
  if [[ -e /opt/dizcord/times/"$STEAMID".online ]]; then
    # if the player was online get the time that the player was online and add it to the total for that player
    GAMESTART=$(cat /opt/dizcord/times/"$STEAMID".online)
    GAMEEND=$(date +%s)
    GAMETIME=$(( GAMEEND - GAMESTART ))
    touch /opt/dizcord/times/"$STEAMID".total
    echo "$GAMETIME" >> /opt/dizcord/times/"$STEAMID".total
    rm /opt/dizcord/times/"$STEAMID".online
  fi

  # Session Time
  if [[ $GAMETIME -eq 0 ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$LAVENDER\", \"title\": \"The mods on the server appear to be out of date.\", \"description\": \"Restarting the server to update all mods.\nPlease wait a minute before rejoining.\" }] }" $URL
    /opt/dizcord/restart.sh &
    exit
  else
    if [[ $GAMETIME -ge 86400 ]]; then
      UPTIME=$(printf '%dd %dh %dm %ds' $((GAMETIME/86400)) $((GAMETIME%86400/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
    elif [[ $GAMETIME -ge 3600  ]]; then
      UPTIME=$(printf '%dh %dm %ds' $((GAMETIME/3600)) $((GAMETIME%3600/60)) $((GAMETIME%60)))
    elif [[ $GAMETIME -ge 60 ]]; then
      UPTIME=$(printf '%dm %ds' $((GAMETIME/60)) $((GAMETIME%60)))
    else
      UPTIME=$(printf '%ds' $((GAMETIME)))
    fi
  fi

  # Total Time
  TOTAL=$(awk '{ sum += $1 } END { print sum }' /opt/dizcord/times/"$STEAMID".total)

  if [[ $TOTAL -ge 604800 ]]; then
    LIFE=$(printf '%dw %dd %dh %dm %ds' $((TOTAL/604800)) $((TOTAL/86400)) $((TOTAL%86400/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
  elif [[ $TOTAL -ge 86400 ]]; then
    LIFE=$(printf '%dd %dh %dm %ds' $((TOTAL/86400)) $((TOTAL%86400/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
  elif [[ $TOTAL -ge 3600  ]]; then
    LIFE=$(printf '%dh %dm %ds' $((TOTAL/3600)) $((TOTAL%3600/60)) $((TOTAL%60)))
  elif [[ $TOTAL -ge 60 ]]; then
    LIFE=$(printf '%dm %ds' $((TOTAL/60)) $((TOTAL%60)))
  else
    LIFE=$(printf '%ds' $((GAMETIME)))
  fi

  HOURTIME=$(awk '{ sum += $1 } END { print sum }' /opt/dizcord/times/"$STEAMID".total)
  if [[ $HOURTIME -ge 3600  ]]; then
    HOURS=$(printf '%d Hours' $((HOURTIME/3600)))
  fi

  # do a lookup to get image name
  IMGNAME=$(grep -E "$STEAMID" "/opt/dizcord/playerdb/users.log" | awk '{print $NF}')
  # if the player died in game and is now rage-quitting, let's shame the hell out of them.
  if [[ -e /tmp/"$STEAMID".dead ]]; then
    RAGE=("Looks like **$STEAMNAME's** exit was more dramatic than their survival skills." \
      "Quitting is easy, surviving is hard. **$STEAMNAME**, the zombies miss you." \
      "**$STEAMNAME** decided to take a break from survival." \
      "The apocalypse is tough, but **$STEAMNAME** might be tougher?. Don't let a setback keep you down. Rejoin and conquer!" \
      "Rage-quitting won't make the zombies go away, **$STEAMNAME**. Come back and show them who's boss!" \
      "Surviving the apocalypse takes grit, **$STEAMNAME**. Quitting only delays the inevitable. Ready for redemption?" \
      "Even the best stumble. **$STEAMNAME**, the server needs your resilience. Rise from the ashes and reclaim your survival story!" \
      "Zombies: 1, **$STEAMNAME**: 0. Are you going to let them have the last laugh? Get back in there and rewrite the ending!" \
      "Nobody said surviving the apocalypse was easy. **$STEAMNAME**, dust off those setbacks and rejoin the fight!" \
      "Rage-quitting won't erase the past, **$STEAMNAME**. Redemption is just a login away. The zombies are eagerly awaiting your return." \
      "Rage-quitting won't erase your past defeats, **$STEAMNAME**. The apocalypse doesn't forgive, but it does offer second chances. Ready for yours?" \
      "Even the bravest survivors face setbacks. **$STEAMNAME**, the world needs your resilience. Are you up for the challenge?" \
      "Quitting is easy, but survival is an art. **$STEAMNAME**, your canvas awaits. Ready to paint a new masterpiece?" \
      "Rage-quitting is a temporary solution. **$STEAMNAME**, the real challenge is staying and fighting. Ready to prove yourself?" \
      "The zombies might have won this round, but **$STEAMNAME** isn't out for the count. Rejoin and turn the tables on the undead!" \
      "Apocalypse got you down, **$STEAMNAME**? Quitting won't make it any easier. Rise from the ashes and show the zombies what you're made of!" \
      "Survival isn't for the faint-hearted. **$STEAMNAME**, the server misses your resilience. Time to show the undead what you're truly capable of!" \
      "Shame! :bell: Shame! :bell: Shame! :bell: Shame! :bell: Shame! :bell: " \
    )
    SEED
    MESSAGE=${RAGE[ $RANDOM % ${#RAGE[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$STEAMNAME Rage-quit\", \"description\": \"$MESSAGE\n\n$STEAMNAME was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
    rm /tmp/"$STEAMID".dead
  else
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$STEAMNAME has disconnected:\", \"description\": \"$STEAMNAME was online for $UPTIME\nTotal time on server: \n $LIFE \n ($HOURS)\", \"thumbnail\": { \"url\": \"$IMGNAME\"} }] }" $URL
  fi

}

OBIT(){
  # Keep a record of who died
  touch /opt/dizcord/playerdb/obit.log
  echo "$(date +%Y-%m-%d_%H:%M:%S) $DEADPLAYER" >> /opt/dizcord/playerdb/obit.log
  # Do lookup to get dead player's steamID
  STEAMID=$(grep "$DEADPLAYER" /opt/dizcord/playerdb/alias.log | awk '{print $1}')
  # Temporary record for Rage-Quit vs Respawn messages
  touch /tmp/"$STEAMID".dead
  # Lets put in some funny death messages - Credit where credit is due, I took inspiration from https://www.reddit.com/r/projectzomboid/comments/u3pivr/need_helpsuggestionswitty_comments/
  DEAD=(\
    "**$DEADPLAYER** just died." \
    "**$DEADPLAYER** has now made ther contribution to the horde." \
    "**$DEADPLAYER** swapped sides." \
    "**$DEADPLAYER** has now completed their playthough." \
    "**$DEADPLAYER** used the wrong hole." \
    "**$DEADPLAYER** kicked the bucket." \
    "**$DEADPLAYER** decided to try something else (it did not work)." \
    "**$DEADPLAYER** forgot to pay their tribute to the R-N-Geezus." \
    "**$DEADPLAYER** bought the farm." \
    "**$DEADPLAYER** is still walking... breathing... not so much." \
    "**$DEADPLAYER**'s survival story just hit a dead end." \
    "**$DEADPLAYER**'s journey through the apocalypse has come to an abrupt halt." \
    "RIP **$DEADPLAYER** - may your next respawn be more successful." \
    "The zombies threw a party, and **$DEADPLAYER** was the main course." \
    "**$DEADPLAYER** was measured. **$DEADPLAYER** was weighed. **$DEADPLAYER** was found wanting." \
    "Looks like **$DEADPLAYER** just rolled a nat **1**." \
    "Rest in pieces, **$DEADPLAYER**. " \
  )
  SEED
  OBITUARY=${DEAD[ $RANDOM % ${#DEAD[@]} ]}
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"description\": \"$OBITUARY\" }] }" "$URL"
}

STARTUP(){
  # get the start time from file file
  RISING=$(cat /opt/dizcord/times/ININAME-start.time)
  rm /opt/dizcord/times/ININAME-start.time
  RISEN=$(date +%s)
  RISESECS=$(( RISEN - RISING ))
  touch /opt/dizcord/times/ININAME.up
  date +%s > /opt/dizcord/times/ININAME.up

  if [[ $RISESECS -ge 60 ]]; then
    RISETIME=$(printf '%dm %ds' $((RISESECS/60)) $((RISESECS%60)))
  else
    RISETIME=$(printf '%ds' $((RISESECS)))
  fi
  TITLE="Server is now **ONLINE**"
  MESSAGE="Server took $RISETIME to come online."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$LIME\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL
}

SHUTDOWN(){
  #get timestamp from srvr-up.time
  TIMEUP=$(cat /opt/dizcord/times/ININAME.up)
  #calculate up-time
  TIMEDOWN=$(date +%s)
  UPSECS=$(( TIMEDOWN - TIMEUP ))
  if [[ $UPSECS -ge 86400 ]]; then
    UPTIME=$(printf '%dd %dh %dm %ds' $((UPSECS/86400)) $((UPSECS%86400/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 3600  ]]; then
    UPTIME=$(printf '%dh %dm %ds' $((UPSECS/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 60 ]]; then
    UPTIME=$(printf '%dm %ds' $((UPSECS/60)) $((UPSECS%60)))
  else
    UPTIME=$(printf '%ds' $((UPSECS)))
  fi

  MESSAGE="The Server was up for $UPTIME"
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESSAGE\" }] }" $URL
}

READER(){
  # Read the output from the SCREEN LOG.
  #tail -Fn0 /tmp/PZ.log 2> /dev/null | \
  tail -Fn0 /home/USERPLACEHOLDER/Zomboid/server-console.txt 2> /dev/null | \
  while read -r LINE ; do

    # CONNECTION STUFF
    STEAMID=$(echo "$LINE" | grep -E '\[fully-connected\]' | grep -E -o 'steam-id=[0-9]+' | awk -F= '{print $2}')
    CONNIP=$(echo "$LINE" | grep -E -o 'ip=[0-9.]*' | awk -F= '{print $2}')
    LOGINNAME=$(echo "$LINE" | grep -E -o 'username=.*' | awk -F'"' '{print $2}')
    # If player was denied access then
    if [[ -n "$CONN_AUTH_DENIED" ]]; then
      DENIED
    else # Otherwise (they were granted access)
      if [[ -n $STEAMID ]]; then
        if [[ -e /opt/dizcord/playerdb/"$STEAMID".online ]]; then
          REJOIN
        else
          JOIN
        fi
      fi
    fi

    # CHOPPER STUFF - Populate the variables if they match
    CHOP_ACTIVE=$(echo "$LINE" | grep -E -i 'chopper: activated')
    CHOP_ARRIVE=$(echo "$LINE" | grep -E -i 'state Arriving -> Hovering')
    CHOP_SEARCH=$(echo "$LINE" | grep -E -i 'state Hovering -> Searching')
    CHOP_LEAVE=$(echo "$LINE" | grep -E -i 'Searching -> Leaving')
    EHE_LAUNCH=$(echo "$LINE" | grep -E -o 'SCHEDULED-LAUNCH.*id:[a-z_]*' | awk -F: '{print $NF}') # Start of EHE
    EHE_TARGET=$(echo "$LINE" | grep -E -o 'Target:.*' | awk -F: '{print $NF}') # Who it's targeting
    EHE_CRASH=$(echo "$LINE" | grep -E -o "$EHE_LAUNCH.*crashing:.*" | awk -F: '{print $NF}') # Are we crashing?
    EHE_CRASH_LOG=$(echo "$LINE" | grep -E -o "stopAllHeldEventSounds for HELI") # Gonna Crash? - not sure about this one BREAKPOINT
    EHE_ROAMING=$(echo "$LINE" | grep -E "roaming") # Hanging around a bit I guess?
    EHE_FLY_OVER=$(echo "$LINE" | grep -E "FLEW OVER TARGET \(.*" | awk -F"(" '{print $NF}' | rev | cut -c3- | rev) # Flying over player
    EHE_GO_HOME=$(echo "$LINE" | grep -E "UN-LAUNCH") # End of event
    CONN_AUTH_DENIED=$(echo "$LINE" | grep -E -o 'Client sent invalid server password')
    EHE_CLASS=$(echo "$LINE" | grep -E -o "---.*target" | awk -F"(" '{print $2}' | awk -F")" '{print $1}')

    # Put all the variables in an array
    CHOPPER_VARS=("CHOP_ACTIVE" "CHOP_ARRIVE" "CHOP_SEARCH" "CHOP_LEAVE" "EHE_LAUNCH" "EHE_TARGET" "EHE_CRASH" "EHE_CRASH_LOG" "EHE_ROAMING" "EHE_FLY_OVER" "EHE_CLASS")
    # check if any of them is not empty and call the CHOPPER function
    for CALL_CHOPPER in "${CHOPPER_VARS[@]}"; do
      if [[ -n "${!CALL_CHOPPER}" ]]; then
        CHOPPER
        break
      fi
    done

    # DISCONNECTION STUFF
    DISCONN=$(echo "$LINE" | grep -E '\[disconnect\]')
    if [[ -n "$DISCONN" ]]; then
      DISCON
    fi

    # OBITUARY STUFF
    DEADPLAYER=$(echo "$LINE" | grep -E -o '\S+\sdied' | awk '{print $1}')
    if [[ -n "$DEADPLAYER" ]]; then
      OBIT
    fi

    # SHUTDOWN STUFF
    ENDOFLINE=$(echo "$LINE" | grep -E -o 'command\sentered\svia\sserver\sconsole\s\(System\.in\):\s\"quit\"')
    if [[ -n $ENDOFLINE ]]; then
      SHUTDOWN
    fi

  done
}

INIT(){
  tail -Fn0 /home/USERPLACEHOLDER/Zomboid/server-console.txt 2> /dev/null | \
  while read -r LINE ; do
    # SERVER STARTUP STUFF
    SRVRUP=$(echo "$LINE" | grep -E -c "SERVER STARTED")
    ALREADY_LIVE=$(echo "$LINE" | grep -E -c "item  0\s*nil")
    if [[ "$SRVRUP" -gt "0" ]]; then
      STARTUP
      return
    fi
    if [[ "$ALREADY_LIVE" -gt 0 ]];  then
      READER
      return
    fi
  done
}

# we reun init first so that the reader doesn't inspect hundreds of lines of code like 30 times
INIT
# once the server has started, we can start reading it for all the other shit
READER

# NOTES
# Run PZ in it's own screen with a log output to /tmp/PZ.log
# Run this script in it's own screen session.
# Run OBIT in a screen session - output death logs to /tmp/PZ.log

