#!/bin/bash

# Global variables
STARTINI=()
ENDDOTS=""

# Set up directories
I_AM=$(whoami)
sudo mkdir -p /opt/dizcord/playerdb/html /opt/dizcord/times /opt/dizcord/boidbot
sudo chown -R "$I_AM":"$I_AM" /opt/dizcord

# FUNCTIONS

# Setting up the crontab to restart the server
ADDCRON(){

    EVERY=" * * *"
  COMMAND="/opt/dizcord/restart.sh"

    # Ask the user how many times a day they want to restart the server (options: 0, 1, 2, 3, 4)
  RESTART_FREQUENCY=$(whiptail --title "Restart Frequency" --menu "How many times a day do you want to restart the server?" 15 80 5 "0" "No automatic restart" "1" "Once a day" "2" "Every 12 hours" "3" "Every 8 hours" "4" "Every 6 hours" 3>&1 1>&2 2>&3)

    case $RESTART_FREQUENCY in
        0)
      # Remove the scheduled restart from crontab
      #crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
      whiptail --title "Scheduling removed" --msgbox "The scheduled server restart has been removed and will now *not* restart on a daily basis." 8 80
      echo $CRONINS
      SCHEDULE="false"
      SCHEDULEMIN=""
      SCHEDULEHRS=""
      ;;

          1)
      # Validate and ask the user to enter a valid time using whiptail
      while true; do
        RESTART_TIME=$(whiptail --title "Restart Time" --inputbox "Enter the restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)

                # Validate the time format (24-hour format)
        if [[ "$RESTART_TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
        fi
      done
      CRONMIN=$(echo "$RESTART_TIME" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS=$(echo "$RESTART_TIME" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONINS="$CRONMIN $CRONHRS $EVERY $COMMAND"

            # Remove the existing schedule and add the new one
      crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
      (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
      #echo $CRONINS
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

          2)
      # Validate and ask the user to enter a valid time using whiptail
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)

                # Validate the time format (24-hour format)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
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
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(echo "$CRONHRS1 $CRONHRS2" | tr ' ' '\n' | sort -n | tr '\n' ',')
      CRONINS="$CRONMIN ${CRONHRS%,*} $EVERY $COMMAND"

            # Remove the existing schedule and add the new one
      crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
      (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
      #echo $CRONINS
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

          3)
      # Validate and ask the user to enter a valid time using whiptail
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)

                # Validate the time format (24-hour format)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
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
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(echo "$CRONHRS1 $CRONHRS2 $CRONHRS3" | tr ' ' '\n' | sort -n | tr '\n' ',')
      CRONINS="$CRONMIN ${CRONHRS%,*} $EVERY $COMMAND"

            # Remove the existing schedule and add the new one
      crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
      (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
      #echo $CRONINS
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

          4)
      # Validate and ask the user to enter a valid time using whiptail
      while true; do
        RESTART_TIME1=$(whiptail --title "Restart Time" --inputbox "Enter first restart time (24-hour format, e.g., 13:30):" 10 80 3>&1 1>&2 2>&3)

                # Validate the time format (24-hour format)
        if [[ "$RESTART_TIME1" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
          break
        else
          whiptail --title "Invalid Time" --msgbox "Please enter a valid time in 24-hour format (e.g., 13:30)." 10 80
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
      CRONMIN=$(echo "$RESTART_TIME1" | awk -F":" '{print $2}' | sed 's/^0//')
      CRONHRS1=$(echo "$RESTART_TIME1" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS2=$(echo "$RESTART_TIME2" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS3=$(echo "$RESTART_TIME3" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS4=$(echo "$RESTART_TIME4" | awk -F":" '{print $1}' | sed 's/^0//')
      CRONHRS=$(echo "$CRONHRS1 $CRONHRS2 $CRONHRS3 $CRONHRS4" | tr ' ' '\n' | sort -n | tr '\n' ',')
      CRONINS="$CRONMIN ${CRONHRS%,*} $EVERY $COMMAND"

            # Remove the existing schedule and add the new one
      crontab -l | grep -v '/opt/dizcord/restart.sh' | crontab -
      (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
      #echo $CRONINS
      SCHEDULE="true"
      SCHEDULEHRS="$CRONHRS"
      SCHEDULEMIN="$CRONMIN"
      ;;

          *)
      ;;
  esac
}

# Function to prompt the user for a server name
ASK(){
  GENERATED_NAMES=0
  # Prompt the user to enter a server name
  SERVER_NAME=$(whiptail --title "Server Name" --inputbox "Please enter a server name for your Project Zomboid server.\n\nIf left blank, a random name will be generated." 12 80 3>&1 1>&2 2>&3)

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
      whiptail --title "Generated Name" --yesno "Generated Server Name: $RANDOM_SERVER_NAME\n\nIs this name acceptable?" 10 80

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

VALIDATE_WEBHOOK() {
  # Function to validate Discord Webhook
  local HOOKREGEX="^https://discord\.com/api/webhooks/[0-9]+/[a-zA-Z0-9_-]+$"
  [[ $1 =~ $HOOKREGEX ]]
}

WELCOME(){
  # Welcome screen
  whiptail --title "Project Zomboid Server Integration" --msgbox "Welcome to the installation wizard.\n\nThis tool will help you integrate your Project Zomboid Server with your Discord server.\n\nYou should already have your Project Zomboid Server set up and running." 16 80
}

SETTINGSCHECK(){
  # Does settings file exist, and if it does, ask if the user wants to create a new server or change existing settings
  SETNUM=$(find /opt/dizcord/ -type f -name "settings-*" | wc -l)
  if [[ $SETNUM -eq 1 ]]; then
    ######
    ## if there's one existing settings file
    ######
    SETFILE="" #create variable
    SETFILE=$(cat $(find /opt/dizcord/ -type f -name "settings-*") | jq -r '.server'
    whiptail --title "Existing Install found" --yesno --yes-button "Update" --no-button "New Instance" "The settings for $SETFILE were found. Would you like to update them or create a new instance?" 26 80
    if [[ $? = 1 ]]; then
      ######
      # code to change existing file
      # change - we could bring up all the settings into a menu and ask which one to change
      ######
    else
      # code to create new instance
    fi
  elif [[ $SETNUM -gt 1 ]]; then
    ######
    ## if there are more than one existing settings files
    ######
    SETFILE=() #create array
    while IFS= read -r line; do
      SETFILE+=("$line")
    done < <(find /opt/dizcord/ -type f -name "settings-*" -exec cat {} \; | jq -r '.server')
    MENU_ITEMS=()
    for ((i=0; i<${#SETFILE[@]}; i++)); do
      MENU_ITEMS+=("$((i+1))" "${SETFILE[i]}")
    done
    SELECTEDINI=$(whiptail --menu "Select option" 15 60 6 "${MENU_ITEMS[@]}" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then
      #this will select the $SETFILE to the one that was selected.
      ${SETFILE[$((SELECTEDINI-1))]}
      ######
      #Now we need to grab all the settings from the file and allow the usert to 1: change 2: delete or 3: create new
      # change - we could bring up all the settings into a menu and ask which one to change
      # delete - big red confirmation
      # create new - continue as per normal
      ######
    else
      exit
    fi
  else
    # no settigns exist - continue as normal
  fi
 }

 LICENSE(){
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

  if whiptail --title "GNU GPL v3 License" --yesno "$LICENSE_TEXT" 26 80; then
    echo -e "You can find a copy of this license is in /opt/dizcord/licence.txt"
  else
    exit
  fi
}

FINDINI(){
  # FIND THE INI FILES
  INIARR=()

    # Display 'working' indication
  echo -n "Finding Server configuration files, please wait."

    # Start the loop in the background
  while true; do
    echo -n "."
    sleep 0.5
    if [ -f "/tmp/stop_dots" ]; then
      break
    fi
  done &

    # Store the background process ID
  DOTS_PID=$!

    # Find files
  while IFS= read -r -d $'\0'; do
      INIARR+=("$REPLY" "")
  done < <(find / -type f -path "*/Zomboid/Server/*.ini" -print0 2>/dev/null)

    # Signal the end of the dots
  touch "/tmp/stop_dots"

    # Wait for the background process to finish
  wait $DOTS_PID
  echo ""
  rm "/tmp/stop_dots"

    if [ "${#INIARR[@]}" -eq 0 ]; then
    # Ask for installation directory if servername.ini is not found
    INILOCATION=$(whiptail --inputbox "I could not find the Project Zomboid installation. Please enter the full path to the .INI file for your Project Zomboid Server:" 10 80 3>&1 1>&2 2>&3)

        # Validate the directory
    if [ -z "$INILOCATION" ]; then
      # If the installation directory is empty, show an error and exit
      whiptail --title "Error" --msgbox "Installation directory cannot be empty. Exiting." 10 80
      exit 1
    fi
  elif [ "${#INIARR[@]}" -eq 1 ]; then
    # Display the single result and ask for confirmation
    whiptail --title "Confirm Config File" --yesno "I found a Project Zomboid configuration file called $INIARR.\n\nIs this the correct config file from your server?" 10 80

        # Check the user's choice
    if [ $? -eq 0 ]; then
      # If the user confirms, set INIFILE to the found directory
      INILOCATION="$(echo $INIARR | awk -F"/" '{$NF=""}1' | sed -e 's/ /\//g')"
    else
      # Ask the user to manually enter the installation directory
      INILOCATION=$(whiptail --inputbox "Please enter the full path to the .INI file for Project Zomboid (including the file itself):" 10 80 3>&1 1>&2 2>&3)
    fi
  else
    # give a list of found INI files to the user and ask them which one they want to use.
    INIARR=()
    while IFS=  read -r -d $'\0'; do
      INIARR+=("$REPLY" "")
    done < <(find / -type f -path "*/Zomboid/Server/*.ini" -print0 2>/dev/null)
    SELINI=()
    for ((i = 0; i < ${#INIARR[@]}; i+=2)); do
      if [ $i -eq 0 ]; then
        SELINI+=( "${INIARR[i]}" "${INIARR[i+1]}" on )
      else
        SELINI+=( "${INIARR[i]}" "${INIARR[i+1]}" off )
      fi
    done
    INIFILE=$(whiptail --title "Select the correct INI file" --radiolist "Please select the .INI file for your Server.\n\nSpace to select, Enter to lock it in." 20 80 "${#SELINI[@]}" "${SELINI[@]}" 3>&1 1>&2 2>&3)
    STARTINI=$(echo $INIFILE | awk -F "/" '{print $NF}' | rev | cut -c5- | rev)
  fi
}

HUMANNAME(){
# Ask the user to enter a server name
SERVER_NAME=""

# Call the ASK function
ASK
}

DISCORDHOOK(){
  # Ask the user to enter a valid Discord webhook
  WEBHOOK=""
  while true; do
    WEBHOOK=$(whiptail --title "Discord Webhook" --inputbox "Please enter the Discord server's full webhook." 12 80 "" 3>&1 1>&2 2>&3)

        # Check if the user pressed Cancel
    if [ $? -ne 0 ]; then
      exit 1
    fi

        # Validate the entered webhook using the regex
    if VALIDATE_WEBHOOK "$WEBHOOK"; then
      break
    else
      whiptail --title "Invalid Webhook" --msgbox "The entered Discord webhook is invalid. Please enter a valid webhook URL." 10 80
    fi
  done

    # Generate a random 6-digit number and save it to the variable OTP
  OTP=$(printf '%06d\n' "$(shuf -i0-999999 -n1)")

    # Send a message to the Discord server with the generated OTP
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"8388736\", \"title\": \"Verification Code\", \"description\": \"Please enter these numbers into the Discord installation wizard:\\n\\n$OTP\" }] }" "$WEBHOOK"


  # Prompt the user for the 6-digit number sent to Discord
  USER_INPUT=""
  while [ "$USER_INPUT" != "$OTP" ]; do
    USER_INPUT=$(whiptail --title "Verification Code" --inputbox "Please enter the 6-digit verification code sent to Discord:" 12 80 3>&1 1>&2 2>&3)
    # Check if the user clicked "Cancel" and exit the script
    if [ $? -ne 0 ]; then
      exit
    fi
  done
}

DISCORDBOT(){
  # Ask the user to enter the bot token
  TOKEN=""
  while true; do
    TOKEN=$(whiptail --title "Discord Webhook" --inputbox "Please enter the full toekn for your bot." 12 80 "" 3>&1 1>&2 2>&3)

    # Check if the user pressed Cancel
    if [ $? -ne 0 ]; then
      exit 1
    fi
}

CRONTAB(){
  # Do we want the Project Zomboid server to start automatically when the server boots up?
  whiptail --title "Start on reboot" --yesno "Do you want the Project Zomboid server to start automatically when the server boots up?" 10 80

    if [[ $? -eq 0 ]]; then
    CRONINS="@reboot /opt/dizcord/start.sh"
    (crontab -l ; echo "$CRONINS") | sort - | uniq - | crontab -
    RESTARTONREBOOT="true"
  else
    crontab -l | grep -v '/opt/dizcord/start.sh' | crontab - 2>/dev/null
    RESTARTONREBOOT="false"
  fi

    # Lets deal with restarting on a daily basis
  # Check if there's a restart command in crontab
  if [[ $(sudo grep -c '/opt/dizcord/restart.sh' /var/spool/cron/crontabs/"$I_AM") -eq 1 ]]; then
    # Get the minute and hour values from the crontab entry
    MIN=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$I_AM" | awk '{printf $1}')
    HRS=$(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$I_AM" | awk '{printf $2}')
    # Check if multiple hours are specified
    if [[ $(sudo grep 'dizcord/restart.sh' /var/spool/cron/crontabs/"$I_AM" | awk '{print $2}' | grep -c ",") -gt 0 ]]; then
      # There are multiple hours are specified
      # Extract and format the restart times
      MULTIPLE=" these times"
    else
      MULTIPLE=""
    fi
    RESTART_TIMES=$(echo $HRS | awk -v MIN="$MIN" -F, '{for(i=1; i<=NF; i++) {printf "%02d:%02d\n", $i, MIN}}')

        whiptail --title "Cronjob Times" --yesno "The Project Zomboid Server is currently configured to restart at$MULTIPLE:\n\n$RESTART_TIMES\n\nDo you want to keep this schedule?" 15 80
    SETCRON=$(echo $?)

        if [[ $SETCRON -eq 0 ]]; then
      whiptail --title "Schedule maintained" --msgbox "No changes made to the restart schedule." 8 78
      SCHEDULE="true"
      SCHEDULEHRS="$HRS"
      SCHEDULEMIN="$MIN"
    else
      ADDCRON
    fi

      else
    whiptail --title "Cronjob Times" --yesno "\
  The Project Zomboid Server is not currently configured to restart automatically\n\n\
  Restarting the server help with performance and cleanup the environment. As an added\
  benefit, it'll also reset loot inside containers to be replaced with\ndifferent\
  materials (if you have loot respawn set up). It also allows the server to update mods\n\n
  Would you like to set up automatic restarts?" 17 80
  SETCRON=$(echo $?)
    if [[ $SETCRON -eq 0 ]]; then
      ADDCRON
    else
      whiptail --title "Schedule maintained" --msgbox "No changes made to the restart schedule." 8 78
      SCHEDULE="false"
      SCHEDULEHRS=""
      SCHEDULEMIN=""
    fi
  fi
}

DOWNLOAD(){
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
  for FILE in /opt/dizcord/kill.sh /opt/dizcord/obit.sh /opt/dizcord/reader.sh /opt/dizcord/restart.sh /opt/dizcord/start.sh; do
    # replace home directory name
    sed -i "s/USERPLACEHOLDER/$I_AM/g" "$FILE"
    # replace webhooks
    sed -i "s!WEBHOOKPLACEHOLDER!$WEBHOOK!g" "$FILE"
    # replace human readable server name
    sed -i "s/HRNAME/$SERVER_NAME/g" "$FILE"
    # replace the server's ini name
    sed -i "s/ININAME/$STARTINI/" "$FILE"
  done

    # Good, now let's make sure that everything is executable
  sudo chmod ug+x /opt/dizcord/*.sh
  # send start and restart links to home directory
  ln -s /opt/dizcord/restart.sh /home/"$I_AM"/restart.sh 2>/dev/null
  ln -s /opt/dizcord/start.sh /home/"$I_AM"/start.sh 2>/dev/null

}

INSTRUCTIONS(){
  whiptail --title "How to use." --msgbox "Once you are all done here, head to your home directory and start the Project Zomboid server by typing:\n\n\
  ./start.sh\n\n\
  Once the Project Zomboid Zomboid server is running, to restart it, enter the following in your home directory:\n\n\
  ./restart.sh\n\n\
  And that's pretty much it, you're good to go!" 18 80
}


THANKS(){
  whiptail --title "Thanks for using dizcord." --msgbox "
  Maybe consider a small donation?\n\
  \n\n\n\
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
  \n\n\n\
  The QR Code goes to my Ko-fi site.\n\n\
  But if you don't trust it - that's fine, head to:\n\
  https://ko-fi.com/blyzz" 32 80
}

SAVE(){
  # Write settings to file
  COMMA=$(echo "$SCHEDULEHRS" | sed 's/,$//')
  SCHEDULEHRS="$COMMA"
  echo -e "{
  \"user\": \"$I_AM\",
  \"file\": \"$INIFILE\",
  \"INI\": \"$STARTINI\",
  \"server\": \"$SERVER_NAME\",
  \"url\": \"$WEBHOOK\",
  \"token\": \"$TOKEN\",
  \"startonboot\": \"$RESTARTONREBOOT\",
  \"daily\": \"$SCHEDULE\",
  \"dailyH\": \"$SCHEDULEHRS\",
  \"dailyM\": \"$SCHEDULEMIN\",
  \"version\": \"$CURRENT_VERSION\"
  }" > /opt/dizcord/"settings-$INI.ini"
  # # User that installed diZcord
  # user=$I_AM
  # # Location of INI file including full path
  # file=$INIFILE
  # # INI File name - used to start the server
  # INI=$STARTINI
  # # Human-readable server name
  # server=$SERVER_NAME
  # # Discord webhook URL
  # url=$WEBHOOK
  # # Restart server on reboot?
  # start-on-boot=$RESTARTONREBOOT
  # #Scheduled restarts
  # daily=$SCHEDULE
  # dailyH=$SCHEDULEHRS
  # dailyM=$SCHEDULEMIN
  # # The current version of diZcord
  # version=$CURRENT_VERSION
}

WELCOME
SETTINGSCHECK
LICENSE
FINDINI
HUMANNAME
DISCORDHOOK
DISCORDBOT
CRONTAB
DOWNLOAD
INSTRUCTIONS
THANKS
SAVE
