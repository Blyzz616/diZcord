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

---

**Installation**:

Open a terminal to your server and make sure that all the dependencies are installed:

```
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl screen sed grep whiptail xargs jq
```

Most of these are installed by default on most distros.

Before starting, shut down your **Project Zomboid** server by entering `quit` into the server's console as an admin.

Create a new file in your home folder called `init.sh` with the following code in there *(I'll describe it line-for-line later)*:

```
#! /bin/bash
LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')
CURRENT_VERSION=$(sudo cat /opt/dizcord/current.version 2>/dev/null)
I_AM=$(whoami)
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
```

Make the script executable:

```
sudo usermod ug+x init.sh
```

Then run the script
```
./init.sh
```

It will download the latest version of diZcord from here and put all the files in `/opt/dizcord/`

Now head on over to /opt/dizcord/

```
cd /opt/dizcord/
```

Run the install wizard:

```
./wizard.sh
```

---

_Explanation of the init.sh file:_

1. `LATEST_VERSION=$(curl -sL https://api.github.com/repos/Blyzz616/diZcord/releases/latest | jq -r '.tag_name')`


    **curl -sL**: This command is used to make an HTTP GET request to the specified URL (https://api.github.com/repos/Blyzz616/diZcord/releases/latest).<br>
    **| jq -r '.tag_name'**: The output of the curl command is passed through jq, a lightweight and flexible command-line JSON processor. This part extracts the value of the 'tag_name' key from the JSON response, effectively retrieving the latest version of the diZcord release from GitHub. The result is stored in the variable `LATEST_VERSION`.


2. `CURRENT_VERSION=$(sudo cat /opt/dizcord/current.version 2>/dev/null)`

    **sudo cat /opt/dizcord/current.version**: Reads the content of the file /opt/dizcord/current.version.
    **2>/dev/null**: Redirects any error output to /dev/null (a special file that discards the output). If the file doesn't exist or there is an error reading it, this line won't produce an error message. The result is stored in the variable `CURRENT_VERSION`.


3. `I_AM=$(whoami)`: Retrieves the current username and assigns it to the variable `I_AM`.


4. `if [[ "$CURRENT_VERSION" != "$LATEST_VERSION" ]]; then`: Checks whether the current version (`$CURRENT_VERSION`) is not equal to the latest version (`$LATEST_VERSION`).

5. `NO_V=$(echo "$LATEST_VERSION" | sed 's/v//')`: Removes the leading 'v' from the latest version and assigns the result to the variable `NO_V`.

6. `sudo mkdir -p /opt/dizcord/`: Creates the directory /opt/dizcord/ if it doesn't exist.

7. `wget -q -O "/tmp/dizcord-$NO_V.tar.gz" "https://github.com/Blyzz616/diZcord/archive/$LATEST_VERSION.tar.gz"`: Downloads the diZcord release tarball (zip file) from GitHub and saves it as `/tmp/dizcord-$NO_V.tar.gz`.

8. `tar -zxvf "/tmp/dizcord-$NO_V.tar.gz" -C /opt/dizcord/ --strip-components=1 >/dev/null`: Extracts the contents of the tarball to `/opt/dizcord/` while suppressing output.

9. `sudo chown -R "$I_AM":"$I_AM" /opt/dizcord`: Changes the ownership of the /opt/dizcord/ directory and its contents to the current user.

10 `rm -r /tmp/di?cord*`: Removes temporary files in /tmp/ that match the pattern /tmp/di?cord*.

11. `echo "$LATEST_VERSION" > /opt/dizcord/current.version`: Writes the latest version to the file /opt/dizcord/current.version.

12. `fi`: Ends the if block.

13. `sudo chmod ug+x /opt/dizcord/*.sh`: Changes the permissions of all .sh files in the /opt/dizcord/ directory to make them executable by the owner and the owner's group.


As all the code in `wizard.sh` is in github, all are free to view it and inspect it. You can even paste it into a GPT and ask a Generative LLM if there is any malicious code in there.

---

**How to use diZcord:**

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

If anyone is online in your Project Zomboid server , it will give them 5 minutes to get to safety. It will also anounce this in-game. You can also shorten that 5 minutes when you enter the restart command like so:

```
./restart <option>
```

where <option> can be "`1`", "`2`", "`3`", "`4`", "`5`" or "`now`"

The script will start Project Zomboid in it's own Screen session to ensure that you can log out of the server session without killing your PZ server. To access the screen session:

```
screen -r PZ
```

To exit the screen session without killing the server: <kbd>Ctrl</kbd>+<kbd>A</kbd> then <kbd>Ctrl</kbd>+<kbd>D</kbd>

---

_**Payoff:**_

Now join your Project Zomboid server and watch discord for all the glory.

---

_Known bugs / To Do:_

- [ ] get diZcord in Steam Workshop?
- [ ] Wizard: add option to support multiple Zomboid servers
- [ ] Detect previous installation
  - [ ] ask if we want to set up a new server or change existing settings
- [ ] fix connect in reader so that pings are displayed
- [ ] Wizard: Ask if installer should advertise on Discord (don't remember what this was)
- [ ] Get Expanded Helicopter Events working
- [ ] Allow for multiple PZ servers on one box
- [ ] refactor to Python?
- [x] Possibly merge all monitoring files to run in one script?
- [x] re-write wizard to work with new file structure
- [x] Wizard: add option to overwrite old settings
- [x] Add [send "quit" to screen] for graceful shutdown
- [x] Add per-user time logging (session/all-time)
- [x] Get Steam Icon working when it is a GIF
- [x] clean code to use best practices
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

Project Whiptail: ***COMPLETE! OMG***
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
- [x] Have Instruction as last page how to control the server using scripts.
