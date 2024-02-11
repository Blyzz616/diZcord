#! /bin/bash

URL='WEBHOOKPLACEHOLDER'

arrNAME=()
WORKSHOP=()
WORKSHOP=$(grep -e '^Workshop' /home/USERPLACEHOLDER/Zomboid/Server/pei.ini | awk -F= '{print $2}' | sed 's/;/\n/g')

for i in $WORKSHOP
do

wget -q -O /opt/dizcord/mods/$i  https://steamcommunity.com/sharedfiles/filedetails/changelog/$i

if [[ $(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $4}') = "@" ]]; then
  YEAR=$(date +%Y)
  HOUR=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' 2757712197 | head -n1 | awk '{print $5}' | rev | cut -c3- | rev | awk -F: '{print $1}')
  UPDATEMIN=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $5}' | rev | cut -c3- | rev | awk -F: '{print $2}')
else
  YEAR=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $4}')
  HOUR=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $6}' | rev | cut -c3- | rev | awk -F: '{print $1}')
  UPDATEMIN=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $6}' | rev | cut -c3- | rev | awk -F: '{print $2}')
fi
MONTH=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $3}' | sed 's/,//')
PREDAY=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 | awk '{print $2}')
if [[ "$PREDAY" -lt 10 ]]; then
  DAY="0$PREDAY"
else
  DAY="$PREDAY"
fi

MERIDIAN=$(grep -o -e 'Update:\s[0-9 a-zA-Z,]*@\s[0-9:amp]*' $i | head -n1 |awk '{print $5}' | rev | cut -c 1-2 | rev)


case $MONTH in

  Jan)
    MONTHNUM=1
    ;;

  Feb)
    MONTHNUM=2
    ;;

  Mar)
    MONTHNUM=3
    ;;

  Apr)
    MONTHNUM=4
    ;;

  May)
    MONTHNUM=5
    ;;

  Jun)
    MONTHNUM=6
    ;;

  Jul)
    MONTHNUM=7
    ;;

  Aug)
    MONTHNUM=8
    ;;

  Sep)
    MONTHNUM=9
    ;;

  Oct)
    MONTHNUM=10
    ;;

  Nov)
    MONTHNUM=11
    ;;

  Dec)
    MONTHNUM=12
    ;;

esac

if [[ "$MONTHNUM" -lt 10 ]]; then
  MONTH=$(echo "0$MONTHNUM")
else
  MONTH="$MONTHNUM"
fi


if [[ "$MERIDIAN" = "am" ]]; then
  #if am
  if [[ "$HOUR" -lt 10 ]]; then
    UPDATEHOUR="0$HOUR"
  fi
else
  #if pm
  if [[ "$HOUR" -eq 12 ]]; then
    UPDATEHOUR="12"
  else
    UPDATEHOUR=$(( "$HOUR" + 12 ))
  fi
fi
#echo $i
NAME=$(grep -o -e ':: .*::' $i | head -n1 | sed 's/:/*/g')
echo "$NAME"
DIFF=$(( $(date +%s) - $(date -d "$YEAR-$MONTH-$DAY $UPDATEHOUR:$UPDATEMIN:00" +%s) ))
echo "$DIFF"
if [[ "$DIFF" -lt 300000 ]]; then
  arrNAME+=("$NAME\n")
#  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"$ORANGE\", \"title\": \"The following mods on the server appear to be out of date.\n$arrNAME\", \"description\": \"Restarting the server to update all mods.\nPlease wait a minute before rejoining.\" }] }" $URL
#  /opt/dizcord/restart.sh
#echo ""
fi

done

if [[ $(echo ${#arrNAME[@]}) -ge 1 ]]; then
  curl -H "Content-Type: application/json" -X POST -d "{\"embeds\": [{ \"color\": \"16753920\", \"title\": \"The following mods on the server appear to be out of date.\", \"description\": \"\n${arrNAME[*]}\nRestarting the server to update all mods.\nPlease wait a minute before rejoining.\" }] }" $URL
fi
