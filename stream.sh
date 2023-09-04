#! /bin/bash

[[ -e /home/pzuser2/Zomboid/server-console.txt ]] && tail -n35 /home/pzuser2/Zomboid/server-console.txt | grep -v -e "^$" > /var/www/html/stream.txt


READER(){

  tail -Fn0 /home/pzuser2/Zomboid/server-console.txt 2> /dev/null | \
  while read -r line ; do

    ###########################################################################
    ######  Stream contents to file to be displayed on site
    ###########################################################################

  tail -n30 /home/pzuser2/Zomboid/server-console.txt | grep -v -e "^$" > /var/www/html/stream.txt
  sed -i s/\$/"<br>"/ /var/www/html/stream.txt
  cat /var/www/html/head.txt /var/www/html/stream.txt /var/www/html/tail.txt > /var/www/html/stream.html

  done

}

READER
