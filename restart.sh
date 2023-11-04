#!/bin/bash

URL='https://discord.com/api/webhooks/'

# File containing all the colours we use in discord
source /opt/dizcord/colours.dec

# this file to limit the server-down notificaiton to 1
touch /tmp/dwn.cmd
echo "0" > /tmp/dwn.cmd

TIMECALC () {
  #get timestamp from srvr-up.time
  TIMEUP=$(</tmp/srvr2-up.time)
  #calculate up-time
  TIMEDOWN=$(date +%s)
  UPSECS=$(( TIMEDOWN - TIMEUP ))
  if [[ $UPSECS -ge 86400 ]];
  then
    UPTIME=$(printf '%dd %dh %dm %ds' $((UPSECS/86400)) $((UPSECS%86400/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 3600  ]];
  then
    UPTIME=$(printf '%dh %dm %ds' $((UPSECS/3600)) $((UPSECS%3600/60)) $((UPSECS%60)))
  elif [[ $UPSECS -ge 60 ]];
  then
    UPTIME=$(printf '%dm %ds' $((UPSECS/60)) $((UPSECS%60)))
  else
    UPTIME=$(printf '%ds' $((UPSECS)))
  fi
}

# This process warns players that the server will be going down in X minutes specified in the restart command
SHUTDOWNWARNING(){
  case "$1" in
    1)
    MINUTE="MINUTE"
    /opt/dizcord/onemin.sh &
    ;;

    2)
    MINUTE="MINUTES"
    /opt/dizcord/twomin.sh &
    ;;

    3)
    MINUTE="MINUTES"
    /opt/dizcord/threemin.sh &
    ;;

    4)
    MINUTE="MINUTES"
    /opt/dizcord/fourmin.sh &
    ;;

    5)
    MINUTE="MINUTES"
    /opt/dizcord/fivemin.sh &
    ;;

    *)
    echo "Incorrect time variable passed to SHUTDOWNWARNING Function" > /tmp/dizcord.err
    ;;
  esac

  NOTICE="**Rotting Domain** server going down in ***$1 $MINUTE*** for maintenance."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"description\": \"$NOTICE\" }] }" "$URL"

  sleep $((60*"$1"))
  SHUTDOWN
}

# This funciton will initiate a shutdown process that posts the uptime to discord
SHUTDOWN(){
  TIMECALC
  MESSAGE="The Server was up for $UPTIME"
  DOWN="**Blighted Dominion** server going down now."
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$RED\", \"title\": \"$DOWN\", \"description\": \"$MESSAGE\" }] }" $URL

  screen -S PZ-obit -X stuff "^C"
  screen -S PZ-reader -X stuff "^C"
  sleep 2
  screen -S PZ-obit -X stuff "exit ^M"
  screen -S PZ-reader -X stuff "exit ^M"


  if [[ "$EMPTY" -gt "0" ]]; then # Check if variable $EMPTY is greater than 0
    touch /tmp/restart.log # Create or update a file called restart.log in the /tmp directory
    echo "BP0" >> /tmp/restart.log # Append "BP0" to the restart.log file
    CONNECTED=() # Initialize an empty array named CONNECTED
    # Ok, let's kick these lazy buggers out
    screen -S PZ -X stuff "players ^M" # Send the command 'players' to screen session PZ
    echo "BP1" >> /tmp/restart.log # Append "BP1" to the restart.log file
    if [[ $(grep -c "command not found" /tmp/PZ.log) -gt 0 ]]; then # Check if 'command not found' is in the log file - if it is, this means that the server has already exited.
      echo "BP2" >> /tmp/restart.log # Append "BP2" to the restart.log file
      screen -S PZ -X stuff "exit^M" # Send 'exit' to screen session PZ
    else
      echo "BP3" >> /tmp/restart.log # Append "BP3" to the restart.log file
      tail -Fn0 /home/pz1/Zomboid/server-console.txt 2> /dev/null | \
      while read -r line; do # Read each line in the console log
        if [[ -z "$line" ]]; then # If the line is empty it means that the list has completed and we can start processing the CONNECTED variable.
          echo "BP4" >> /tmp/restart.log # Append "BP4" to the restart.log file
          for element in "${CONNECTED[@]}"; do
            echo "BP0" >> /tmp/restart.log # Append "BP0" to the restart.log file
            screen -S PZ -X stuff "kickuser \"$element\" -r \"You were warned\" ^M" # Kick connected players with a warning message
          done
          break # Exit the loop
        else # the linbe was not empty, meaning that it's still listing connected players. Appent the player names to the CONNECTED variable
          echo "BP5" >> /tmp/restart.log # Append "BP5" to the restart.log file
          PLAYER=$(echo "$line" | cut -c2-) # Extract the player name from the line
          CONNECTED+=("$PLAYER") # Add the player to the CONNECTED array
        fi
      done
    fi
  else
    echo "BP6" >> /tmp/restart.log # Append "BP6" to the restart.log file
    screen -S PZ -X stuff "quit^M" # Send 'quit' to screen session PZ
    tail -Fn0 /home/pz1/Zomboid/server-console.txt 2> /dev/null | \ # Start tailing the Zomboid server console log
    while read -r line; do # Read each line in the console log
      echo "BP7" >> /tmp/restart.log # Append "BP7" to the restart.log file
      DOWNSVR=$(echo "$line" | grep -c -E "SSteamSDK: LogOff") # Search for 'SSteamSDK: LogOff' in the line
      if [[ "$DOWNSVR" -eq 1 ]]; then # Check if 'SSteamSDK: LogOff' is found
        echo "BP8" >> /tmp/restart.log # Append "BP8" to the restart.log file
        if [[ $(</tmp/dwn.cmd) -eq 0 ]]; then # Check if the content of dwn.cmd is equal to 0
          echo "BP9" >> /tmp/restart.log # Append "BP9" to the restart.log file
          echo "1" > /tmp/dwn.cmd # Write '1' to the dwn.cmd file
          screen -S PZ -X stuff "^C" # Send Ctrl+C to screen session PZ
          sleep 5 # Wait for 5 seconds
          screen -S PZ -X stuff "exit ^M" # Send 'exit' to screen session PZ
          /usr/local/bin/pz1/start.sh & # Fire the server up again.
          break # Exit the loop
        fi
      fi
    done
  fi
  exit

}

# This function will check for players, if there are none, it will immediately run the shutdown() funciton and kill the server
PLAYERCHECK(){
  screen -S PZ -X stuff "players ^M"

  tail -Fn0 /home/pz1/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line; do
    EMPTY=$(echo "$line" | grep -o -E "Players connected \([0-9]" | awk -F"(" '{print $NF}')
    if [[ "$EMPTY" -ge 1 ]];
    then
      SHUTDOWNWARNING "$RESTARTTIMER"
      break
    elif [[ "$EMPTY" -eq 0 ]];
    then
      NOTICE="No-one on **Rotting Domain** right now, skipping warnings."
      curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"description\": \"$NOTICE\" }] }" "$URL"
      SHUTDOWN
    fi
  done
}

if [[ -z "$1" ]];
then
  RESTARTTIMER="5"
  PLAYERCHECK
else
  RESTARTTIMER="$1"
  case "$1" in
    now)
    SHUTDOWN
    ;;

    0)
    SHUTDOWN
    ;;

    [1-5])
    PLAYERCHECK
    ;;

    *)
    echo "Please pick a number between 0 and 5 and try again."
    exit
    ;;
  esac
fi
