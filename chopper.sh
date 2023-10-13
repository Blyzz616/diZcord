#! /bin/bash

# ADD YOUR DISCORD WEBHOOK TO THE NEXT LINE
URL='https://discord.com/api/webhooks/'

# EHE handling
EHE_TYPE="/opt/pzserver2/dizcord/ehe.type"

touch /home/pzuser2/crash.true

RED=16711680
ORANGE=16753920
CHARTREUSE=8388352
DISCORDBLUE=45015

READER(){
  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ###########################################################################
    ###### Chopper Event Stuff
    ###########################################################################

    # We're gonna need a seed
    RANDOM=$$$(date +%s)

    CHOP_ACTIVE=$(echo "$line" | grep -E -i 'chopper: activated')
    CHOP_ARRIVE=$(echo "$line" | grep -E -i 'state Arriving -> Hovering')
    CHOP_SEARCH=$(echo "$line" | grep -E -i 'state Hovering -> Searching')
    CHOP_LEAVE=$(echo "$line" | grep -E -i 'Searching -> Leaving')

    ##########################################
    ######                              ######
    ######  Expanded Helicopter Events  ######
    ######                              ######
    ##########################################

    # Event Starting
    EHE_LAUNCH=$(echo "$line" | grep -E -o 'SCHEDULED-LAUNCH.*id:[a-z_]*' | awk -F: '{print $NF}')
    # Who it's targeting
    EHE_TARGET=$(echo "$line" | grep -E -o 'Target:.*' | awk -F: '{print $NF}')
    # Are we crashing?
    EHE_CRASH=$(echo "$line" | grep -E -o "$EHE_LAUNCH.*crashing:.*" | awk -F: '{print $NF}')
    # Gonna Crash?
    EHE_CRASH_LOG=$(echo "$line" | grep -E -o "stopAllHeldEventSounds for HELI")
    # Hanging around a bit I guess?
    EHE_ROAMING=$(echo "$line" | grep -E "roaming")
    # Flying over player
    EHE_FLY_OVER=$(echo "$line" | grep -E "FLEW OVER TARGET \(.*" | awk -F"(" '{print $NF}' | rev | cut -c3- | rev)
    # End of event
    EHE_GO_HOME=$(echo "$line" | grep -E "UN-LAUNCH")

    if [[ -n $CHOP_ACTIVE ]];
    then
      RAND_ACTIVE=(\
        "What was that?" \
        "Did you hear something" \
        "What was that sound?" \
        "Do you hear something?" \
        "Uhm, I think we might have a problem..." \
        "Shh shh shh shh, listen..." \
        "Wait, QUIEIT! I think I hear something" \
      )
      MESS_ACTIVE=${RAND_ACTIVE[ $RANDOM % ${#RAND_ACTIVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
    fi

    if [[ -n $CHOP_ARRIVE ]];
    then
      RAND_ARRIVE=(\
        "Is that a helicopter?" \
        "Kinda sounds like a motorbike." \
        "Whoa! Is that Search and Rescue?" \
        "Is is a bird? A plane? Nope...  just a chopper" \
      )
      MESS_ARRIVE=${RAND_ARRIVE[ $RANDOM % ${#RAND_ARRIVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ARRIVE\" }] }" $URL
    fi

    if [[ -n $CHOP_SEARCH ]];
    then
    RAND_SEARCH=(\
      "Why is it flying back and forth like that?" \
      "I think it might be looking for us!." \
      "I think that he is flying a search pattern" \
      "If he keeps flying around like that he'll bring down a horde on us!" \
    )
    MESS_SEARCH=${RAND_SEARCH[ $RANDOM % ${#RAND_SEARCH[@]} ]}
    curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
    fi

    if [[ -n $CHOP_LEAVE ]];
    then
      RAND_LEAVE=(\
        "Wait... Why is he leaving?" \
        "Phew, he is leaving, I think we may be safe now." \
        "Yeah, thats right, fly away and don't come back!" \
        "I think we're truly alone now." \
        "I think were safe. For the time being." \
      )
      MESS_LEAVE=${RAND_LEAVE[ $RANDOM % ${#RAND_LEAVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" $URL
    fi

    ###################
    ######       ######
    ######  EHE  ######
    ######       ######
    ###################

    if [[ -n "$EHE_LAUNCH"  ]];
    then
      touch "$EHE_TYPE"
      echo "$EHE_LAUNCH" > "$EHE_TYPE"
      RAND_EHE=(\
        "What was that?" \
        "Did you hear something?" \
        "What was that sound?" \
        "Do you hear something?" \
        "Uhm, I think we may have a problem..." \
        "Shh shh shh shh, listen..." \
        "Wait, QUIEIT! I think I hear something" \
        )
        MESS_ACTIVE=${RAND_EHE[ $RANDOM % ${#RAND_EHE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
    fi

    if [[ -n "$EHE_TARGET" ]];
    then
      if ! [[ "$EHE_TARGET" =~ [0-9]+,\s[0-9]+ ]];
      then
        RAND_EHE=(\
          "Uhm **$EHE_TARGET**, I think you might want to get ready?" \
          "**$EHE_TARGET**, you might want to think about arming yourself." \
          "I think he saw you **$EHE_TERGET!**. RUN!" \
          )
          MESS_ACTIVE=${RAND_EHE[ $RANDOM % ${#RAND_EHE[@]} ]}
        curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
      fi
    fi

    if [[ "$EHE_CRASH" = "true" ]];
    then
      touch /home/pzuser2/crash.true
      echo "true" > "/home/pzuser2/crash.true"
      RAND_EHE=(\
        "Whoa! Did you see that?" \
        "I think somthing... Hit? It??" \
        "Was that an explosion?" \
        "Is it on fire?" \
        "Hey Hey Hey!, I think he may be in trouble! " \
        "What the hell?" \
        "Oh. My. God! I think he's going down!" \
        )
        MESS_ACTIVE=${RAND_EHE[ $RANDOM % ${#RAND_EHE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$DISCORDBLUE\", \"title\": \"$TITLE\", \"description\": \"$MESS_ACTIVE\" }] }" $URL
    fi

    if [[ -n "$EHE_CRASH_LOG" ]];
    then
      if [[ $(cat /home/pzuser2/crash.true) = "true" ]];
      then
        touch /home/pzuser2/crash.log
        tail -n50 /home/pzuser2/Zomboid/server-console.txt | grep -B10 -A10 -E "crashing:true" > /home/pzuser2/crash.log
      fi
    fi
    if [[ -n "$EHE_ROAMING" ]];
    then
      case $EHE_TYPE in

        survivor_smallplane)
          RAND_EHE=(\
            "Why is it flying back and forth like that?" \
            "I think it might be looking for us!." \
            "I think that he is flying a search pattern" \
            "If he keeps flying around like that he'll bring down a horde on us!" \
          )
          ;;

        raiders)
          RAND_EHE=(\
            "What the hell was that?" \
            "WHAT. IS. HE. DOING" \
            "WHY IS HE PLAYING THAT AWFUL MUSIC?" \
            "Why? Why? Why do this to us?" \
            "What is this guy's problem" \
            "Who **IS** that? What did we ever do to him?" \
            "OMG! He's gonna bring the whole horde down on us! Get Ready!" \
          )
          ;;

        survivor_heli)
          RAND_EHE=(\
            "Why is it flying back and forth like that?" \
            "I think it might be looking for us!." \
            "I think that he is flying a search pattern" \
            "If he keeps flying around like that he will bring down a horde on us!" \
          )
          ;;

        *)
          RAND_EHE="New EHE event- check /home/pzuser2/newEHE.log"
          touch /home/pzuser2/newEHE.log
          tail -n20 /home/pzuser2/Zomboid/server-console.txt | grep -B10 -A10 -E 'SCHEDULED-LAUNCH.*id:[a-z_]*' >> /home/pzuser2/newEHE.log
          ;;
      esac

      MESS_SEARCH=${RAND_EHE[ $RANDOM % ${#RAND_EHE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
    fi
    if [[ -n "$EHE_FLY_OVER" ]];
    then
      ############################
      ############################
      #  NEED TO TIE USER
      #  NAME TO CHARACTERNAME
      #  THEN SEND LOOK OUT
      #  NOTICE IN DISCROD
      #  NOT SURE THIS IS POSSIBLE
      ############################
      ############################
      RAND_EHE=(\
        "Whoa! I think he flew RIGHT over you there **$EHE_FLY_OVER**" \
        "Wow! Was he aiming fore you **$EHE_FLY_OVER**?" \
      )
      MESS_SEARCH=${RAND_EHE[ $RANDOM % ${#RAND_EHE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$TITLE\", \"description\": \"$MESS_SEARCH\" }] }" $URL
    fi
    if [[ -n "$EHE_GO_HOME" ]];
    then
      RAND_LEAVE=(\
        "Wait... Why is he leaving?" \
        "Phew, he's leaving, I think we may be safe now." \
        "I think we are truly alone now" \
      )
      MESS_LEAVE=${RAND_LEAVE[ $RANDOM % ${#RAND_LEAVE[@]} ]}
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$CHARTREUSE\", \"title\": \"$TITLE\", \"description\": \"$MESS_LEAVE\" }] }" $URL
    fi

   # Clear chopper variables
    unset CHOP_ACTIVE
    unset CHOP_ARRIVE
    unset CHOP_SEARCH
    unset CHOP_LEAVE

    ###### End of Chopper Event stuff

  done

}

READER

# EVERYTHING below is commented out - just more info on the EHE events, some log file stuff

:<<'COMMENT'


EHE EVENT 1
  [EHE]: SCHEDULED-LAUNCH INFO:  [5] - day:133 time:17 id:survivor_smallplane done:false
  -- EHE: IsoPlayers adding:Yi Hurt
  -- [eHeliEvent_engage]: HELI HELI  SYSTEM selecting targets <150> x
  -- Target: zombie.characters.IsoPlayer@3d6b255f: Yi Hurt
  -- EHE: IsoPlayers adding:Yi Hurt
  -- EHE:XY:  MIN_X:4261 MAX_X:5857 MIN_Y:5297 MAX_Y:6368
  --- HELI 4 (survivor_smallplane) [gotoTarget] crashChance:49.5 crashing:false
  -- EHE: LAUNCH: HELI 4 (survivor_smallplane) [gotoTarget] day:141 hour:17
  -- EHE: HELI 4 (survivor_smallplane) [gotoTarget]  -roaming + set target to random square
  - HELI 4 (survivor_smallplane) [arrived] (x:5296, y:5809)  - FLEW OVER TARGET (Yi Hurt)
  --- HELI HELI 4 (survivor_smallplane) [goHome]: setting fixed course.
 - EHE: OUT OF BOUNDS: HELI 4 (survivor_smallplane) [goHome] (x:4794, y:6369)
  ---- UN-LAUNCH: HELI 4 (survivor_smallplane) [goHome] (x:4794, y:6369) day:141 hour:18
  - EHE: stopAllHeldEventSounds for HELI 4 (survivor_smallplane) [goHome]


  -- EHE: HELI 1 (survivor_heli) [gotoTarget]  -roaming + set target to random square
  - HELI 1 (survivor_heli) [arrived] (x:5426, y:6190)  - FLEW OVER TARGET zombie.characters.IsoZombie@6c1e4574
  --- HELI HELI 1 (survivor_heli) [goHome]: setting fixed course.
 - EHE: OUT OF BOUNDS: HELI 1 (survivor_heli) [goHome] (x:5157, y:6606)
  ---- UN-LAUNCH: HELI 1 (survivor_heli) [goHome] (x:5157, y:6606) day:145 hour:12
  - EHE: stopAllHeldEventSounds for HELI 1 (survivor_heli) [goHome]
  -Scheduled: survivor_smallplane [Day:133 Time:14]
  [EHE]: SCHEDULED-LAUNCH INFO:  [7] - day:133 time:14 id:survivor_smallplane done:false
  -- EHE: IsoPlayers adding:Yi Hurt
  -- [eHeliEvent_engage]: HELI HELI  SYSTEM selecting targets <60> x
  -- Target: zombie.characters.IsoZombie@700a970b: Yvonne Acosta
  -- EHE: IsoPlayers adding:Yi Hurt
  -- EHE:XY:  MIN_X:4841 MAX_X:5860 MIN_Y:5295 MAX_Y:6297
  --- HELI 2 (survivor_smallplane) [gotoTarget] crashChance:61.5 crashing:false
  -- EHE: LAUNCH: HELI 2 (survivor_smallplane) [gotoTarget] day:145 hour:14
  [EHE]: SCHEDULED-LAUNCH INFO:  [8] - day:133 time:14 id:survivor_smallplane done:false
  -- EHE: IsoPlayers adding:Yi Hurt
  -- [eHeliEvent_engage]: HELI HELI  SYSTEM selecting targets <60> x
  -- Target: zombie.characters.IsoZombie@7675271a: Tonya Barton
  -- EHE: IsoPlayers adding:Yi Hurt
  -- EHE:XY:  MIN_X:4841 MAX_X:5860 MIN_Y:5295 MAX_Y:6297
  --- HELI 3 (survivor_smallplane) [gotoTarget] crashChance:61.5 crashing:false
  -- EHE: LAUNCH: HELI 3 (survivor_smallplane) [gotoTarget] day:145 hour:14
 -- EHE: HELI 3 (survivor_smallplane) [gotoTarget]  -found target outside: zombie.characters.IsoZombie@7675271a
 -- EHE: HELI 3 (survivor_smallplane) [gotoTarget]  -roaming + set target to random square
 -- EHE: HELI 2 (survivor_smallplane) [gotoTarget]  -found target outside: zombie.characters.IsoZombie@700a970b
 -- EHE: HELI 3 (survivor_smallplane) [gotoTarget]  -found target outside: zombie.characters.IsoZombie@7675271a
 - HELI 3 (survivor_smallplane) [arrived] (x:5320, y:5734)  - FLEW OVER TARGET zombie.characters.IsoZombie@7675271a
 --- HELI HELI 3 (survivor_smallplane) [goHome]: setting fixed course.
 - HELI 2 (survivor_smallplane) [arrived] (x:5293, y:5833)  - FLEW OVER TARGET zombie.characters.IsoZombie@700a970b
 --- HELI HELI 2 (survivor_smallplane) [goHome]: setting fixed course.


 found luaObject without an isoObject
  [EHE]: SCHEDULED-LAUNCH INFO:  [15] - day:133 time:17 id:raiders done:false
  -- [eHeliEvent_engage]: HELI HELI  SYSTEM selecting targets <30> x
  -- randomSelectPreset:   pool size: 4   choice: raider_heli_passive
  -- Target: zombie.characters.IsoZombie@6c23b25: Masako Wagner
  -- EHE: IsoPlayers adding: Misty Hitt
  -- EHE: IsoPlayers adding:Rogers Shaw
  -- EHE:XY:  MIN_X:4802 MAX_X:5848 MIN_Y:5317 MAX_Y:6470
  --- HELI 2 (raider_heli_passive) [gotoTarget] crashChance:61 crashing:false
  -- EHE: LAUNCH: HELI 2 (raider_heli_passive) [gotoTarget] day:156 hour:17
 null
  -- EHE: HELI 2 (raider_heli_passive) [gotoTarget]  -roaming + set target to random square
  - HELI 2 (raider_heli_passive) [arrived] (x:5370, y:5806)  - FLEW OVER TARGET zombie.characters.IsoZombie@6c23b25
  --- HELI HELI 2 (raider_heli_passive) [goHome]: setting fixed course.
 null
 - EHE: OUT OF BOUNDS: HELI 2 (raider_heli_passive) [goHome] (x:5145, y:5316)
  ---- UN-LAUNCH: HELI 2 (raider_heli_passive) [goHome] (x:5145, y:5316) day:156 hour:18
  - EHE: stopAllHeldEventSounds for HELI 2 (raider_heli_passive) [goHome]
 null


survivor_smallplane
survivor_smallplane
survivor_smallplane
raiders

COMMENT
