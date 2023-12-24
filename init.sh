#! /bin/bash

# Get latest version from github
LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')

# Get current version
CURRENT_VERSION=$(sudo cat /opt/dizcord/current.version)

# get current user name
I_AM=$(whoami)

# Update if necessary
if [[ "$CURRENT_VERSION" !=  "$LATEST_VERSION" ]]; then
  NO_V=$(echo "$LATEST_VERSION" | sed 's/v//')
  wget -O "/tmp/dizcord-$NO_V.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"
  tar -zxvf "/tmp/dizcord-$NO_V.tar.gz" -C /tmp
  sudo mkdir -p /opt/dizcord/
  sudo cp -r "/tmp/diZcord-$NO_V/." /opt/dizcord
  sudo chown -R "$I_AM":"$I_AM" /opt/dizcord
  rm -r /tmp/dizcord*
  echo "$LATEST_VERSION" > /opt/dizcord/current.version
fi

sudo chmod ug+x /opt/dizcord/*.sh
