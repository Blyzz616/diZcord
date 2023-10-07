# diZcord
Project Zomboid / Discord integration

![What the discord integration looks like](https://i.imgur.com/Xa4TcU1.jpeg)

![When a player joins](https://github.com/Blyzz616/diZcord/assets/19424317/3995e12d-710d-4890-ba2a-09fb460e2230)

![When a player disconnects](https://github.com/Blyzz616/diZcord/assets/19424317/8d8bdb05-7d7a-4ed0-aa18-96f1e87c7a62)

![Server reboot](https://github.com/Blyzz616/diZcord/assets/19424317/2b7ea92c-263e-4720-b6ff-c5cb81d4bc29)

**# PZ-Disco**
Discord integration for Project Zomboid

**Requirements**
Ok, So this needs to be run on the instance that is running the Project Zomboid server.
Obviously the OS needs to be Linux with Bourne Again Shell (BASH) and a few other dependencies, listed later.
You'll also have to have your own Discord Server (or have admin rights to the server) to get a Webhook set up.
The user that you use to install diZcord should have sudo access.

_File list:_

~~The install wizard creates more executable scripts in /opt/disboid/ and one (start.sh) which is created in your home folder these are described below~~ (Will re-do this when it is working again)

- start.sh - starts the server in a screen instance so that it will not be closed accidentally
- restart.sh - Accepts inputs of "now" and "1" to "5" (./restart 4 will begin shutting down the server in 4 minutes)
  - When restarting with no arguments, it defaults to a 5-minute restart
  - Unless there are no users connected, in which case it starts shutting down immediately
  - when there are users connected and the restart is set to 1 to 5, a number of warnings are sent to the in-game notification system warnning connected players
- startup.sh - Announces when the server has finished starting up and can accept connections
- connect.sh
  - Announces when a player joins a server and keeps a record of it in playerdb/users.log (one line per user)
    - Fields: First Seen | Steam ID | Steam Name | IP Address | Server Login | Local Image Name | Steam Image Link | Other profiles on server *
  - **Animated GIFS are now supported!**
  - Keeps a record of failed join attempts in playerdb/denied.log
  - Keeps a record of when people joined the server in playerdb/access.log (one line per join)
- discon.sh - Announces when a player leaves the server both when they quit or lose connection - Also Determines if there is workshop mod incompatibility and will restart the server if one exists.
  - **Animated GIFS are now supported!**
- chopper.sh - Announces the different states of the chopper event (with some fun random messages). Busy integrating Expanded Helicopter Events (EHE)
- obit.sh - read a different log file and puts in any deaths that happen on the server
- shutdown.sh - Announces when the server is being taken down with a server-up timer

_Installation:_

Open a terminal to your server and make sure that all the dependencies are installed:

```
sudo apt update -y && sudo apt upgrade -y
sudo apt install curl screen sed grep whiptail
```

All of these are installed by default on most distros.

~~_Then run the wizard:_~~

~~```~~
~~./install-wizard.sh~~
~~```~~

_Running the scripts:_

Start your server

```
cd ~
sudo ./start.sh
```

**CAUTION!** Running multiple instances of these scripts WILL cause duplicated output in discord.

_Added Extra:_
I include cronjobs to do this all for me

```
sudo crontab -e
```

addthe following lines

```
@reboot         /home/boid/start.sh > /dev/null 2
```

If you have a monitor plugged into your server and you want to use it to watch the raw PZ output like me, add this line as well:

```
@reboot         tail -Fn0 ~/Zomboid/server-console.txt > /dev/tty1
```


_Payoff:_

Now join your Project Zomboid server and watch discord for all the glory.

_Known bugs / To Do:_

The join script is not working so nicely, it isn't displaying the user ping as it should be for some reason. I'll work on it at some point, but for right now, it is working well enough.
- [ ] Possibly merge all monitoring files to run in one script?
- [ ] re-write wizard to work with new file structure
- [ ] fix connect.sh so that pings are displayed correctly
- [ ] Wizard: add option to support multiple Zomboid servers
- [ ] Wizard: add option to overwrite old settings
- [ ] Wizard: Ask if installer should advertise on Discord
- [x] Add [send "quit" to screen] for graceful shutdown
- [x] Add per-user time logging (session/all-time)
- [x] Get Steam Icon working when it is a GIF
- [ ] Get Expanded HElicopter Events working
- [ ] Do the above and 'figger out' how to do it with per-server settings

Notes:
If you get double quit notifications on player disconnect, it may be an anti-cheat problem.
Try disabling anti-cheat 21 & 22 in Zomboid Server configuration.
