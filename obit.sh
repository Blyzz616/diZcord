#! /bin/bash -x


OBITFILE=""

OBITUARY(){
  tail -fn0 "$OBITFILE" | \
  while read -r LINE ; do
    echo "$LINE" >> /home/pz1/Zomboid/server-console.txt

    # test if the OBIT file is still the current log file
    if [[ "$OBITFILE" != $(find /home/pz1/Zomboid/Logs/ -maxdepth 1 -name "*user*" | tail -n1) ]]; then
      OBITFILE="$(find /home/pz1/Zomboid/Logs/ -maxdepth 1 -name '*user*')"
    fi
  done
}

VALIDATE() {
  OBITDIR="/home/pz1/Zomboid/Logs"
  OBITPATTERN=".*user.txt"

  # Check if a matching file already exists
  OBITFILE="$(find $OBITDIR -maxdepth 1 -name '*user*')"
  if [[ -n "$OBITFILE" ]]; then
    # File already exists, proceed to OBITUARY
    OBITUARY
    return
  fi

  # Wait for a file to be created
  while true; do
    created_file=$(inotifywait -q -e create --format "%f" "$OBITDIR" | grep -E "$OBITPATTERN")
    if [[ -n "$created_file" ]]; then
      OBITFILE="$(find $OBITDIR -maxdepth 1 -name '*user*')"
      break
    fi
    sleep 1
  done
  OBITUARY
}

VALIDATE
