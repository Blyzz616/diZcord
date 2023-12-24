#! /bin/bash

# Get latest version from github
LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')

# Get current version
CURRENT_VERSION=$(sudo cat /opt/dizcord/current.version 2>/dev/null)

# get current user name
I_AM=$(whoami)

# Update if necessary
if [[ "$CURRENT_VERSION" !=  "$LATEST_VERSION" ]]; then
  NO_V=$(echo "$LATEST_VERSION" | sed 's/v//')
  sudo mkdir -p /opt/dizcord/
  wget -q -O "/tmp/dizcord-$NO_V.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"
  tar -zxvf "/tmp/dizcord-$NO_V.tar.gz" -C /opt/dizcord/ --strip-components=1 >/dev/null
  sudo chown -R "$I_AM":"$I_AM" /opt/dizcord
  rm -r /tmp/di?cord*
  echo "$LATEST_VERSION" > /opt/dizcord/current.version
fi

sudo chmod ug+x /opt/dizcord/*.sh
