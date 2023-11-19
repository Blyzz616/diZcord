#! /bin/bash

# Get latest version from github
LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')

# Get current version
CURRENT_VERSION=$(/opt/dizcord/current.version)

# Update if necessary
if [[ $CURRENT_VERSION != $  $LATEST_VERSION ]]; then
  wget -O "/tmp/$LATEST_VERSION.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"
  tar -zxvf "/tmp/$LATEST_VERSION.tar.gz" -C /tmp
  mv "/tmp/diZcord-$LATEST_VERSION" /opt/dizcord/
  rm "/tmp$LATEST_VERSION.tar.gz"
  echo "$LATEST_VERSION" > /opt/dizcord/current.version
fi

if [[ $(ps aux | grep ProjectZomboid64 | grep -v grep | wc -l ) -eq 1 ]]; then
  /opt/dizcord/restart.sh &
  exit
else
  /opt/dizcord/start.sh &
  exit
fi
