# diZcord
Project Zomboid / Discord integration

![What the discord integration looks like](https://i.imgur.com/Xa4TcU1.jpeg)

![When a player joins](https://github.com/Blyzz616/diZcord/assets/19424317/3995e12d-710d-4890-ba2a-09fb460e2230)

![When a player disconnects](https://github.com/Blyzz616/diZcord/assets/19424317/8d8bdb05-7d7a-4ed0-aa18-96f1e87c7a62)

![Server reboot](https://github.com/Blyzz616/diZcord/assets/19424317/2b7ea92c-263e-4720-b6ff-c5cb81d4bc29)

![Discord Server Control](https://github.com/Blyzz616/diZcord/assets/19424317/641c7688-3800-4b34-bfee-895f68943d2a)


**# DiZcord**
Discord integration for Project Zomboid. Sends feature-rich information to a text channel in discord.
I've now also added a discord bot to control the discord server from a discord channel. **BE VERY CAREFUL WITH THIS!**

**Requirements**
Ok, So this needs to be run on the instance that is running the Project Zomboid server.
Obviously the OS needs to be Linux with Bourne Again Shell (BASH) and a few other dependencies, listed later.
You'll also have to have your own Discord Server (or have admin rights to the server) to get a Webhook set up.
The user that you use to install diZcord should have sudo access.

_File list:_

- start.sh - starts the server in a screen instance so that it will not be closed accidentally
- restart.sh - Accepts inputs of "now" and "1" to "5" (./restart 4 will begin shutting down the server in 4 minutes)
  - When restarting with no arguments, it defaults to a 5-minute restart
  - Unless there are no users connected, in which case it starts shutting down immediately
  - when there are users connected and the restart is set to 1 to 5, a number of warnings are sent to the in-game notification system warnning connected players
- obit.sh - read a different log file and outputs into the main output file so that the reader can handle it
- **reader.sh now does all of the below**
- Announces when the server has finished starting up and can accept connections
- Announces when a player joins a server and keeps a record of it in playerdb/users.log (one line per user)
    - Fields: First Seen | Steam ID | Steam Name | IP Address | Server Login | Local Image Name | Steam Image Link | Other profiles on server *
  - **Animated GIFS are now supported!**
- Keeps a record of failed join attempts in playerdb/denied.log
- Annonces any deaths that happen on the server
- If the player quits after dying, a shaming or motivating message displayed about the rage-quit
- If the player created a new character after dying, a different message is disaplayed
- Keeps a record of when people joined the server in playerdb/access.log (one line per join)
- Announces when a player leaves the server both when they quit or lose connection - Also Determines if there is workshop mod incompatibility and will restart the server if one exists.
- Announces the different states of the chopper event (with some fun random messages). Busy integrating Expanded Helicopter Events (EHE)
- Announces when the server is being taken down with a server-up timer

_Installation:_

Open a terminal to your server and make sure that all the dependencies are installed:

```
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl screen sed grep whiptail xargs jq
```

Most of these are installed by default on most distros.


First thing you need to do is create a new file in your home folder. I call mine `init.sh`
put the following code in there

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

Make the script executable
`sudo usermod ug+x init.sh`

Then run the script
`./init.sh`

It will download the latest version of diZcord from here and put all the files in `/opt/dizcord/`

How to use this diZcord:

_Running the scripts:_

Start your server

```
cd ~
./start.sh
```

If the server is already running and you want to restat it:

```
cd ~
./restart.sh
```

IF anyone is online, it will give them 5 minutes to get to safety. It will also anounce this in-game. You can also shorten that 5 minutes when you enter the restart command like so:

```
./restart <option>
```

where <option> can be 1, 2, 3, 4, 5 or now

The script will start PRoject Zomboid in it's own Screen session. To access the screen session:

```
screen -r PZ
```

To exit the screen session without killing the server: `CTRL`+`A` then `CTRL`+`D`



_Payoff:_

Now join your Project Zomboid server and watch discord for all the glory.

_Known bugs / To Do:_

The join script is not working so nicely, it isn't displaying the user ping as it should be for some reason. I'll work on it at some point, but for right now, it is working well enough.
- [x] Possibly merge all monitoring files to run in one script?
- [x] re-write wizard to work with new file structure
- [ ] fix connect.sh so that pings are displayed correctly
- [ ] Wizard: add option to support multiple Zomboid servers
- [x] Wizard: add option to overwrite old settings
- [ ] Wizard: Ask if installer should advertise on Discord (don't remember what this was)
- [x] Add [send "quit" to screen] for graceful shutdown
- [x] Add per-user time logging (session/all-time)
- [x] Get Steam Icon working when it is a GIF
- [ ] Get Expanded Helicopter Events working
- [ ] Do the above and 'figger out' how to do it with per-server settings
- [x] clean code to use best practices
- [ ] refactor to Python?
- [x] Save all settings (server name/ports/webhook url/ etc) for updates
- [x] Change "Last played on" to reflect "today" and "yesterday"
- [x] Add rage quit messages.
- [x] Added logic to recognise when someone dies and creates a new character (respanws) with some cool messages for discord.
- [x] Figure out the server up time with server name in `restart.sh` line 14

Notes:
If you get double quit notifications on player disconnect, it may be an anti-cheat problem.
Try disabling anti-cheat 21 & 22 in Zomboid Server configuration.

And lastly, if you made it this far and want to buy me a beer (or a laptop), please feel free to make a donation on my ko-fi!
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/A0A2RROUR)

Project Whiptail:
- [x] Search for any existing Zomboid installs
- [x] Display ALL Zomboid Installations and ask which this will be for with radio-button style
- [x] Ask for the Server name
- [x] Ask for the webhook
- [x] Send message to web hook to test and ask if message was received
- [x] Ask if crontab entry should be added
- [x] check for existing crontab entries
- [x] Ask how many times a day
- [x] Get the 1st time and calculate other times
- [x] Convert times to crontab format
- [ ] Have Instruction as last page how to control the server using scripts.
- [ ] 
~~Ask if you want bot control~~ (too difficult if prereq not installed)
