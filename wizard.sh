#!/bin/bash

# WELCOME SCREEN
whiptail --title "Project Zomboid Server Integration" --msgbox "Welcome to the installation wizard.\n\nThis tool will help you integrate your Project Zomboid Server with your Discord server." 10 60

# CHECK FOR SERVER-CONSOLE.TXT
RESULTS=($(find / -name server-console.txt 2>/dev/null))

if [ "${#RESULTS[@]}" -eq 0 ]; then
    # ASK FOR INSTALLATION DIRECTORY IF SERVER-CONSOLE.TXT IS NOT FOUND
    INSTALL_DIR=$(whiptail --inputbox "I could not find the Project Zomboid installation directory. Please enter the installation directory for Project Zomboid:" 10 60 3>&1 1>&2 2>&3)

    # VALIDATE THE DIRECTORY
    if [ -z "$INSTALL_DIR" ]; then
        whiptail --title "Error" --msgbox "Installation directory cannot be empty. Exiting." 10 60
        exit 1
    fi
elif [ "${#RESULTS[@]}" -eq 1 ]; then
    # DISPLAY THE SINGLE RESULT AND ASK FOR CONFIRMATION
    PARENT_DIR=$(dirname "${RESULTS[0]}")
    whiptail --title "Confirm Installation Directory" --yesno "I found a Project Zomboid installation in the following directory:\n\n$PARENT_DIR\n\nIs this the correct installation directory?" 10 60

    # CHECK THE USER'S CHOICE
    if [ $? -eq 0 ]; then
        INSTALL_DIR="$PARENT_DIR"
    else
        # ASK THE USER TO MANUALLY ENTER THE INSTALLATION DIRECTORY
        INSTALL_DIR=$(whiptail --inputbox "Please enter the installation directory for Project Zomboid:" 10 60 3>&1 1>&2 2>&3)
    fi
else
    # DISPLAY A LIST OF PARENT DIRECTORIES AND ASK THE USER TO CHOOSE
    OPTIONS=()
    for ((i = 0; i < ${#RESULTS[@]}; i++)); do
        PARENT_DIR=$(dirname "${RESULTS[i]}")
        OPTIONS+=("$i" "$PARENT_DIR")
    done

    SELECTED_INDEX=$(whiptail --title "Select Installation Directory" --menu "Please select the correct installation directory:" 20 60 10 "${OPTIONS[@]}" 3>&1 1>&2 2>&3)

    # SET THE INSTALLATION DIRECTORY TO THE USER'S CHOICE
    INSTALL_DIR="${RESULTS[SELECTED_INDEX]}"
fi

# ASK THE USER TO ENTER A SERVER NAME
SERVER_NAME=""

ASK(){
  GENERATED_NAMES=0
  # PROMPT THE USER TO ENTER A SERVER NAME
  SERVER_NAME=$(whiptail --title "Server Name" --inputbox "Please enter a server name for your Project Zomboid server.\n\nIf left blank, a random name will be generated." 12 60 3>&1 1>&2 2>&3)
  if [[ -z "$SERVER_NAME" ]];then
    SUGGEST
  fi

}

SUGGEST(){
  # IF SERVER NAME IS EMPTY, GENERATE A RANDOM NAME
  while [ $GENERATED_NAMES -lt 3 ]; do
    if [ -z "$SERVER_NAME" ]; then
      GENERATED_NAMES=$((GENERATED_NAMES + 1))
      RANDOM_SERVER_NAME=$(shuf -n 1 -e "Zombocalypse Haven" "Undead Utopia" "Survival Sanctuary" "Outbreak Outpost" "Infected Inn" "Apocalypse Alcove" "Cataclysmic Citadel" "Quarantine Quarter" "Endgame Enclave" "Deadzone Dwelling" "Survival Stronghold" "Pandemic Playground" "Aftermath Asylum" "Undying Utopia" "Blighted Dominion|" "Rotting Domain")

      # ASK THE USER IF THE GENERATED NAME IS ACCEPTABLE
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

ASK

# DISPLAY THE CHOSEN INSTALLATION DIRECTORY AND SERVER NAME
whiptail --title "Installation Summary" --msgbox "Installation Directory: $INSTALL_DIR\nServer Name: $SERVER_NAME\n\nPress OK to proceed with the installation." 10 60

# MORE TO COME
