#!/bin/bash

# Set up directories
sudo mkdir -p /opt/dizcord/playerdb/html /opt/dizcord/times /opt/dizcord/boidbot
sudo chown "$(whoami)":"$(whoami)" /opt/dizcord/playerdb 
sudo chown "$(whoami)":"$(whoami)" /opt/dizcord/playerdb/html
sudo chown "$(whoami)":"$(whoami)"/opt/dizcord/times
sudo chown "$(whoami)":"$(whoami)"/opt/dizcord/boidbot

# Welcome screen
whiptail --title "Project Zomboid Server Integration" --msgbox "Welcome to the installation wizard.\n\nThis tool will help you integrate your Project Zomboid Server with your Discord server.\n\nYou should already have your Project Zomboid Server set up and running." 10 60

# License
LICENSE_TEXT="
GNU General Public License v3.0\n\
\n\
Copyright (c) 2023 Jim Sher\n\
\n\
This program is free software: you can redistribute it and/or modify\n\
it under the terms of the GNU General Public License as published by\n\
the Free Software Foundation\n\
\n\
This program is distributed in the hope that it will be useful,\n\
but WITHOUT ANY WARRANTY; without even the implied warranty of\n\
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the\n\
GNU General Public License for more details.\n\
\n\
You should have received a copy of the GNU General Public License\n\
along with this program. If not, see <https://www.gnu.org/licenses/>.\n\
\n\
By selecting \"Yes\" you agree to the above
"

if whiptail --title "GNU GPL v3 License" --yesno "$LICENSE_TEXT" 26 78; then
  touch /opt/discord/licence.txt
  echo -e "GNU General Public License v3.0
  
Copyright (c) 2023 Jim Sher

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>." > /opt/dizcord/licence.txt
else
  exit
fi

# FIND THE INI FILES
# Function to check if a file exists
file_exists() {
    [ -e "$1" ]
}

# Function to display a dialog and get user input
GET_USER_INPUT() {
    whiptail --inputbox "$1" 8 60 --title "$2" 3>&1 1>&2 2>&3
}

# Function to display a dialog and get user confirmation (yes/no)
GET_USER_CONFIRMATION() {
    whiptail --yesno "$1" 8 60 --title "$2" 3>&1 1>&2 2>&3
}

# Function to display a list dialog and get user selection
GET_USER_SELECTION() {
    whiptail --menu "$1" 20 60 10 "${@:3}" 3>&1 1>&2 2>&3
}

# Function to find files based on the provided pattern
FIND_FILES() {
    find / -type f -path "*/Zomboid/Server/*.ini" 2>/dev/null
}

# Check if the file exists
FILE_PATH=""
while true; do
    FILES=$(FIND_FILES)
    FILE_COUNT=$(echo "$FILES" | wc -l)

    if [ "$FILE_COUNT" -eq 0 ]; then
        # File not found, ask user for full path
        FILE_PATH=$(GET_USER_INPUT "Enter the full path to the file:" "File Not Found")
    elif [ "$FILE_COUNT" -eq 1 ]; then
        # One file found, ask if it's correct
        FILE_PATH=$(echo "$FILES" | head -n 1)
        if ! GET_USER_CONFIRMATION "Is this the correct file?\n$FILE_PATH" "File Confirmation"; then
            FILE_PATH=""
        fi
    else
        # Multiple files found, ask user to select
        FILE_PATHS_ARRAY=("$FILES")
        PATH_OPTIONS=()
        for path in "${FILE_PATHS_ARRAY[@]}"; do
            PATH_OPTIONS+=("$path" "")
        done

        selected_path=$(GET_USER_SELECTION "Select the correct path:" "Path Selection" "${PATH_OPTIONS[@]}")

        # Check if there is only one file in the selected path
        SELECTED_FILES=($(echo "$FILES" | grep "$selected_path"))
        if [ "${#SELECTED_FILES[@]}" -eq 1 ]; then
            FILE_PATH=${SELECTED_FILES[0]}
            if ! GET_USER_CONFIRMATION "Is this the correct file?\n$FILE_PATH" "File Confirmation"; then
                FILE_PATH=""
            fi
        else
            # Multiple files in the selected path, ask user to choose
            FILE_OPTIONS=()
            for FILE in "${SELECTED_FILES[@]}"; do
                FILE_OPTIONS+=("$FILE" "")
            done
            FILE_PATH=$(GET_USER_SELECTION "Select the correct file:" "File Selection" "${FILE_OPTIONS[@]}")
        fi
    fi

done

# Break down the path/file to get server start name
ININAME=$(echo "$FILE_PATH" | awk -F"/" '{print $NF}' | rev | cut -c5- | rev)
touch /opt/dizcord/ini.name
echo "$ININAME" > /opt/dizcord/ini.name

# INIFILE=$(find / -type f -path "*/Zomboid/Server/*.ini" 2>/dev/null | awk -F"/" '{print $NF}')

# if [ "${#INIFILE[@]}" -eq 0 ]; then
#   # Ask for installation directory if servername.ini is not found
#   INILOCATION=$(whiptail --inputbox "I could not find the Project Zomboid installation. Please enter the full path to the .INI file for your Project Zomboid Server:" 10 60 3>&1 1>&2 2>&3)

#   # Validate the directory
#   if [ -z "$INILOCATION" ]; then
#     # If the installation directory is empty, show an error and exit
#     whiptail --title "Error" --msgbox "Installation directory cannot be empty. Exiting." 10 60
#     exit 1
#   fi
# elif [ "${#INIFILE[@]}" -eq 1 ]; then
#   # Display the single result and ask for confirmation
#   whiptail --title "Confirm Config File" --yesno "I found a Project Zomboid configuration file called $INIFILE.\n\nIs this the correct config file from your server?" 10 60

#   # Check the user's choice
#   if [ $? -eq 0 ]; then
#     # If the user confirms, set INIFILE to the found directory
#     INILOCATION="$(echo $INIFILE | awk -F"/" '{$NF=""}1' | sed -e 's/ /\//g')"
#   else
#     # Ask the user to manually enter the installation directory
#     INILOCATION=$(whiptail --inputbox "Please enter the full path to the .INI file for Project Zomboid (including the file itself):" 10 60 3>&1 1>&2 2>&3)
#   fi
# else
#   # Display a list of INI files and ask the user to choose
#   OPTIONS=()
#   for ((i = 0; i < ${#INIFILE[@]}; i++)); do
#     PARENT_DIR=$(dirname "${RESULTS[i]}")
#     OPTIONS+=("$i" "$PARENT_DIR")
#   done

#   SELECTED_INDEX=$(whiptail --title "Select Installation Directory" --menu "Please select the correct installation directory:" 20 60 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

#   # Set the installation directory to the user's choice
#   INILOCATION="${RESULTS[SELECTED_INDEX]}"
# fi

# Use "$FILE_PATH" to get the path to the server INI file.

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
if [[ $(sudo grep -c '/opt/dizcord/restart.sh' /var/spool/cron/crontabs/"$(whoami)") -eq 1 ]]; then
  # Get the minute and hour values from the crontab entry
  MIN=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$(whoami)" | awk '{printf "%02d", $1}')
  
  # Check if multiple hours are specified
  if [[ $(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$(whoami)" | awk '{print $2}' | grep -c ",") -gt 0 ]]; then
    # Extract and format the restart times
    HRS=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$(whoami)" | awk '{printf "%02d", $2}')
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
if [[ "$CURRENT_VERSION" !=  "$LATEST_VERSION" ]]; then
  wget -O "/tmp/$LATEST_VERSION.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"
  tar -zxvf "/tmp/$LATEST_VERSION.tar.gz" -C /tmp
  mv "/tmp/diZcord-${LATEST_VERSION#v}/"* /opt/dizcord/
  sudo chmod ug+x /opt/dizcord/*.sh
  rm "/tmp/$LATEST_VERSION.tar.gz"
  echo "$LATEST_VERSION" > /opt/dizcord/current.version
fi

# Lets replace all the placeholders with their correct values
# replace home directory name
USERHOOK="$(whoami)"
sed -i "s/USERPLACEHOLDER/$USERHOOK/g" /opt/dizcord/*
# replace webhooks
sed -i 's/WEBHOOKPLACEHOLDER/$WEBHOOK/g' /opt/dizcord/*
# replace human readable server name
sed -i 's/HRNAME/$SERVER_NAME/g' /opt/dizcord/*
# replace the server-start name
sed -i 's/ININAME/$ININAME/' /opt/dizcord/*


# Good, now let's make sure that everything is executable
sudo chmod ug+x /opt/dizcord/*.sh
# send start and restart links to home directory
ln -s /opt/dizcord/restart.sh /home/"$(whoami)"/restart.sh
ln -s /opt/dizcord/start.sh /home/"$(whoami)"/start.sh

whiptail --title "Thanks for using dizcord." --msgbox "
Maybe consider a small donation?\n\
\n\
█▀▀▀▀▀█ ▀▄█▄██  ▄ █▀▀▀▀▀█\n\
█ ███ █ ███ ▄██   █ ███ █\n\
█ ▀▀▀ █ ▀ ▄█▀ ▀▀▀ █ ▀▀▀ █\n\
▀▀▀▀▀▀▀ ▀ █ █ █▄█ ▀▀▀▀▀▀▀\n\
▀█▀█▄▄▀▄█ █▀█▄▀▀█▀ ▄▀▀▀▄▀\n\
 █ ▀▄ ▀▀▄██▀▀▄ ▄█▄██▄▄▄  \n\
▀██ ▄█▀▄▄█▀▄██▀█▄▄█▄█ ▀▀█\n\
▄▀▄ █▀▀█ ▄▀█ ▀▄ ███▄█ ▀▀▄\n\
  ▀▀▀▀▀ ██▀ ▀▀▄▀█▀▀▀█▀█▀█\n\
█▀▀▀▀▀█   ▀▄ ▀▄ █ ▀ █ ▀▀█\n\
█ ███ █ ▄▀▄  ▄█ ▀██▀██▄█▄\n\
█ ▀▀▀ █ █ ▀▄▄█▀ ▀█▀ █ █▀ \n\
▀▀▀▀▀▀▀ ▀▀▀▀▀      ▀▀▀▀▀▀\n\
\n\
The QR Code goes to my Ko-fi site" 24 78


if [[ $(ps aux | grep ProjectZomboid64 | grep -v grep | wc -l ) -eq 1 ]]; then
  /opt/dizcord/restart.sh &
  exit
else
  /opt/dizcord/start.sh &
  exit
fi

# DISPLAY THE CHOSEN INSTALLATION DIRECTORY, SERVER NAME, WEBHOOK, AND OTP
#whiptail --title "Installation Summary" --msgbox "Installation Directory: $INILOCATION\nServer Name: $SERVER_NAME\nDiscord Webhook: $WEBHOOK\nOTP: $OTP\n\nPress OK to proceed with the installation." 10 60
