#!/bin/bash

# Set up directories
sudo mkdir -p /opt/dizcord/playerdb /opt/dizcord/times /opt/dizcord/boidbot
sudo chown "$(whoami)":"$(whoami)" /opt/dizcord/playerdb 
sudo chown "$(whoami)":"$(whoami)"/opt/dizcord/times 
sudo chown "$(whoami)":"$(whoami)"/opt/dizcord/boidbot

# Welcome screen
whiptail --title "Project Zomboid Server Integration" --msgbox "Welcome to the installation wizard.\n\nThis tool will help you integrate your Project Zomboid Server with your Discord server.\n\nYou should already have your Project Zomboid Server set up and running." 10 60

# Check for server config file (...../Zomboid/Server/<somename>.ini)
RESULTS=$(find / -type f -path "*/Zomboid/Server/*.ini" 2>/dev/null)
INIFILE=$(find / -type f -path "*/Zomboid/Server/*.ini" 2>/dev/null | awk -F"/" '{print $NF}')

if [ "${#RESULTS[@]}" -eq 0 ]; then
  # Ask for installation directory if servername.ini is not found
  INILOCATION=$(whiptail --inputbox "I could not find the Project Zomboid installation. Please enter the full path to the .INI file for your Project Zomboid Server:" 10 60 3>&1 1>&2 2>&3)

  # Validate the directory
  if [ -z "$INILOCATION" ]; then
    # If the installation directory is empty, show an error and exit
    whiptail --title "Error" --msgbox "Installation directory cannot be empty. Exiting." 10 60
    exit 1
  fi
elif [ "${#RESULTS[@]}" -eq 1 ]; then
  # Display the single result and ask for confirmation
  INIFILE="${RESULTS[0]}"
  whiptail --title "Confirm Config File" --yesno "I found a Project Zomboid configuration file called $INIFILE.\n\nIs this the correct config file from your server?" 10 60

  # Check the user's choice
  if [ $? -eq 0 ]; then
    # If the user confirms, set INILOCATION to the found directory
    INILOCATION="$PARENT_DIR"
  else
    # Ask the user to manually enter the installation directory
    INILOCATION=$(whiptail --inputbox "Please enter the full path to the .INI file for Project Zomboid (including the file itself):" 10 60 3>&1 1>&2 2>&3)
  fi
else
  # Display a list of INI files and ask the user to choose
  OPTIONS=()
  for ((i = 0; i < ${#RESULTS[@]}; i++)); do
    PARENT_DIR=$(dirname "${RESULTS[i]}")
    OPTIONS+=("$i" "$PARENT_DIR")
  done

  SELECTED_INDEX=$(whiptail --title "Select Installation Directory" --menu "Please select the correct installation directory:" 20 60 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

  # Set the installation directory to the user's choice
  INILOCATION="${RESULTS[SELECTED_INDEX]}"
fi

# Ask the user to enter a server name
SERVER_NAME=""

# Function to prompt the user for a server name
ASK(){
  GENERATED_NAMES=0
  # Prompt the user to enter a server name
  SERVER_NAME=$(whiptail --title "Server Name" --inputbox "Please enter a server name for your Project Zomboid server.\n\nIf left blank, a random name will be generated." 12 60 3>&1 1>&2 2>&3)

  # Check if the entered server name is empty
  if [[ -z "$SERVER_NAME" ]]; then
    SUGGEST
  fi
}

# Function to suggest a random server name if the entered one is empty
SUGGEST(){
  # If the server name is empty, generate a random name
  while [ $GENERATED_NAMES -lt 3 ]; do
    if [ -z "$SERVER_NAME" ]; then
      GENERATED_NAMES=$((GENERATED_NAMES + 1))
      RANDOM_SERVER_NAME=$(shuf -n 1 -e "Zombocalypse Haven" "Undead Utopia" "Survival Sanctuary" "Outbreak Outpost" "Infected Inn" "Apocalypse Alcove" "Cataclysmic Citadel" "Quarantine Quarter" "Endgame Enclave" "Deadzone Dwelling" "Survival Stronghold" "Pandemic Playground" "Aftermath Asylum" "Undying Utopia" "Blighted Dominion|" "Rotting Domain")

      # Ask the user if the generated name is acceptable
      whiptail --title "Generated Name" --yesno "Generated Server Name: $RANDOM_SERVER_NAME\n\nIs this name acceptable?" 10 60

      # If the user accepts, set SERVER_NAME and exit the function
      if [ $? -eq 0 ]; then
        SERVER_NAME="$RANDOM_SERVER_NAME"
        return
      fi
    else
      echo "$SERVER_NAME"
      return
    fi
  done
  ASK
}

# Call the ASK function
ASK

# Prompt the user for the Discord server's webhook
WEBHOOK=""
while [ -z "$WEBHOOK" ]; do
  WEBHOOK=$(whiptail --title "Discord Webhook" --inputbox "Please enter the Discord server's webhook:" 12 60 "https://discord.com/api/webhooks/" 3>&1 1>&2 2>&3)
done

# Generate a random 6-digit number and save it to the variable OTP
OTP=$(printf '%06d\n' "$(shuf -i0-999999 -n1)")

# Send a message to the Discord server with the generated OTP
curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"8388736\", \"title\": \"Verification Code\", \"description\": \"Please enter these numbers into the Discord installation wi
zard:\n\n$OTP\" }] }" "$WEBHOOK"

# Prompt the user for the 6-digit number sent to Discord
USER_INPUT=""
while [ "$USER_INPUT" != "$OTP" ]; do
  USER_INPUT=$(whiptail --title "Verification Code" --inputbox "Please enter the 6-digit verification code sent to Discord:" 12 60 3>&1 1>&2 2>&3)
  # Check if the user clicked "Cancel" and exit the script
  if [ $? -ne 0 ]; then
    exit
  fi
done

# Ask the user if they want the server to restart on reboot using whiptail
RESTARTONREBOOT=$(whiptail --yesno "Do you want the server to restart on reboot?" 10 60)

if [[ "$RESTARTONREBOOT" = 0 ]];then
  CRONINS="@reboot /opt/dizcord/start.sh"
  (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
else
  crontab -l | grep -v '/opt/dizcord/start.sh' | crontab - 2>/dev/null
fi

# Check if there's a restart command in crontab
if [[ $(sudo grep -c '/opt/dizcord/restart.sh' /var/spool/cron/crontabs/$(whoami)) -eq 1 ]]; then
  # Get the minute and hour values from the crontab entry
  MIN=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/$(whoami) | awk '{printf "%02d", $1}')
  
  # Check if multiple hours are specified
  if [[ $(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/$(whoami) | awk '{print $2}' | grep -c ",") -gt 0 ]]; then
    # Extract and format the restart times
    HRS=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/$(whoami) | awk '{printf "%02d", $2}')
    RESTART_TIMES=$(echo $HRS | awk -v MIN="$MIN" -F, '{for(i=1; i<=NF; i++) {printf "%02d:%s\n", $i, MIN}}')
    
    # Ask the user if they want to keep the existing cron schedule
    KEEPCRON=$(whiptail --title "Cronjob Times" --yesno "The Project Zomboid Server is currently configured to restart at these times:\n\n$RESTART_TIMES\n\nDo you want to keep these times?" 15 60)
    
    if [[ $KEEPCRON -ne 0 ]]; then # If the user wants to remove/change the times
      # Ask the user if they want to remove or change the schedule
      ALTERCRON=$(whiptail --title "Remove or Change" --menu "What would you prefer to do?" 15 60 2 \
        "1" "Remove the scheduled restart entirely." \
        "2" "Change the times" \
        3>&1 1>&2 2>&3)

      case $ALTERCRON in
        1)
          # Remove the scheduled restart from crontab
          crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
          whiptail --title "Scheduling removed" --msgbox "The scheduled server restart has been removed." 8 78
          ;;

        2)
          # Ask the user how many times a day they want to restart the server (options: 0, 1, 2, 3, 4)
          RESTART_FREQUENCY=$(whiptail --title "Restart Frequency" --menu "How many times a day do you want to restart the server?" 15 60 5 "0" "No automatic restart" "1" "Once a day" "2" "Every 12 hours" "3" "Every 8 hours" "4" "Every 6 hours" 3>&1 1>&2 2>&3)

          case $RESTART_FREQUENCY in
            1)
              # Validate and ask the user to enter a valid time using whiptail
              while true; do
                RESTART_TIME=$(whiptail --title "Restart Time" --inputbox "Enter the restart time (24-hour format, e.g., 13:30):" 10 60 3>&1 1>&2 2>&3)
                
                # Validate the time format (24-hour format)
                if [[ "$RESTART_TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                  break
                else
                  whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 60
                fi
              done
              CRONMIN=$(echo "$RESTART_TIME" | awk -F":" '{print $2}' | sed 's/^0*//')
              CRONHRS=$(echo "$RESTART_TIME" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONINS="$CRONMIN $CRONHRS * * * /opt/dizcord/restart.sh"
              
              # Remove the existing schedule and add the new one
              crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
              (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
              ;;

            2)
              # Validate and ask the user to enter a valid time using whiptail
              while true; do
                RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 60 3>&1 1>&2 2>&3)
                
                # Validate the time format (24-hour format)
                if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                  break
                else
                  whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 60
                fi
              done
              
              # Convert time to date standard timestamp
              TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
              # Seconds in 12 hours
              SECONDS=43200
              # Get second time in date standard timestamp
              TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
              # Convert timestamp2 to actual time
              RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
              RESTART_TIME="$RESTART_TIME1 $RESTART_TIME2"
              CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0*//')
              CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS=$(echo "$CRONHRS1 $CRONHRS2" | tr ' ' '\n' | sort -n | tr '\n' ',')
              CRONINS="$CRONMIN ${CRONHRS%,*} * * * /opt/dizcord/restart.sh"
              
              # Remove the existing schedule and add the new one
              crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
              (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
              ;;

            3)
              # Validate and ask the user to enter a valid time using whiptail
              while true; do
                RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 60 3>&1 1>&2 2>&3)
                
                # Validate the time format (24-hour format)
                if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                  break
                else
                  whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 60
                fi
              done
              
              # Convert time to date standard timestamp
              TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
              # Seconds in 8 hours
              SECONDS=28800
              # Get second time in date standard timestamp
              TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
              TIMESTAMP3=$((TIMESTAMP2 + SECONDS))
              # Convert timestamp2 and timestamp3 to actual time
              RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
              RESTART_TIME3=$(date -d "@$TIMESTAMP3" +%H:%M)
              RESTART_TIME="$RESTART_TIME1 $RESTART_TIME2 $RESTART_TIME3"
              CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0*//')
              CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS=$(echo "$CRONHRS1 $CRONHRS2 $CRONHRS3" | tr ' ' '\n' | sort -n | tr '\n' ',')
              CRONINS="$CRONMIN ${CRONHRS%,*} * * * /opt/dizcord/restart.sh"
              
              # Remove the existing schedule and add the new one
              crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
              (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
              ;;

            4)
              # Validate and ask the user to enter a valid time using whiptail
              while true; do
                RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 60 3>&1 1>&2 2>&3)
                
                # Validate the time format (24-hour format)
                if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                  break
                else
                  whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 60
                fi
              done
              
              # Convert time to date standard timestamp
              TIMESTAMP1=$(date -d "$RESTART_TIME1" "+%s")
              # Seconds in 6 hours
              SECONDS=21600
              # Get second time in date standard timestamp
              TIMESTAMP2=$((TIMESTAMP1 + SECONDS))
              TIMESTAMP3=$((TIMESTAMP2 + SECONDS))
              TIMESTAMP4=$((TIMESTAMP3 + SECONDS))
              # Convert timestamp2 and timestamp3 to actual time
              RESTART_TIME2=$(date -d "@$TIMESTAMP2" +%H:%M)
              RESTART_TIME3=$(date -d "@$TIMESTAMP3" +%H:%M)
              RESTART_TIME4=$(date -d "@$TIMESTAMP4" +%H:%M)
              RESTART_TIME="$RESTART_TIME1 $RESTART_TIME2 $RESTART_TIME3 $RESTART_TIME4"
              CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0*//')
              CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS4=$(echo "$RESTART_TIME4" | awk -F":" '{print $1}' | sed 's/^0*//')
              CRONHRS=$(echo "$CRONHRS1 $CRONHRS2 $CRONHRS3 $CRONHRS4" | tr ' ' '\n' | sort -n | tr '\n' ',')
              CRONINS="$CRONMIN ${CRONHRS%,*} * * * /opt/dizcord/restart.sh"
              
              # Remove the existing schedule and add the new one
              crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
              (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
              ;;

            *)
              ;;
          esac
          ;;

        *)
          ;;
      esac
    fi
  fi
fi

# Ok lets get the scripts themselves from github
# 1st Get latest version from github
LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')

# Get current version
CURRENT_VERSION=$(< /opt/dizcord/current.version)

# Update if necessary
if [[ $CURRENT_VERSION !=  $LATEST_VERSION ]]; then
  wget -O "/tmp/$LATEST_VERSION.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"
  tar -zxvf "/tmp/$LATEST_VERSION.tar.gz" -C /tmp
  mv "/tmp/diZcord-${LATEST_VERSION#v}/"* /opt/dizcord/
  sudo chmod ug+x /opt/dizcord/*.sh
  rm "/tmp/$LATEST_VERSION.tar.gz"
  echo "$LATEST_VERSION" > /opt/dizcord/current.version
fi

# Good, now let's make sure that everything is executable
sudo chmod ug+x /opt/dizcord/*.sh

if [[ $(ps aux | grep ProjectZomboid64 | grep -v grep | wc -l ) -eq 1 ]]; then
  /opt/dizcord/restart.sh &
  exit
else
  /opt/dizcord/start.sh &
  exit
fi

# DISPLAY THE CHOSEN INSTALLATION DIRECTORY, SERVER NAME, WEBHOOK, AND OTP
whiptail --title "Installation Summary" --msgbox "Installation Directory: $INILOCATION\nServer Name: $SERVER_NAME\nDiscord Webhook: $WEBHOOK\nOTP: $OTP\n\nPress OK to proceed with the installation." 10 60

# TO DO Finish it up - make it workable
