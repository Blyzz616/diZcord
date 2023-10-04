# diZcord
Project Zomboid / Discord integreation

![What the discord integration looks like](https://i.imgur.com/Xa4TcU1.jpeg)

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
- startup.sh - Announces when the server has finised starting up and can accept connections
- connect.sh
  - Announces when a player joins a server and keeps a record of it in playerdb/users.log (one line per user)
    - Fields: First Seen | Steam ID | Steam Name | IP Address | Server Login | Local Image Name | Steam Image Link | Other profiles on server *
  - Keeps a record of failed join attempts in playerdb/denied.log
  - Keeps a record of when people joined the server in playerdb/access.log (one line per join)
- discon.sh - Annonces when a player leaves the server both when they quit or lose conneciton - Also Determines if there is workshop mod incompatibility and will restart the server if there is
- chopper.sh - Announces the different states of the chopper event (with some fun random messages) Busy integrating Expanded Helicopter Events (EHE)
- obit.sh - read a different log file and puts in any deaths that happen on the server
- shutdown.sh - Annonces when the server is being taken down with a server-up timer

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
- [ ] re-write wizard to work with new file structure
- [ ] fix connect.sh so that pings are displayed correctly
- [ ] Wizard: add option to support multiple Zomboid servers
- [ ] Wizard: add option to overwite old settings
- [ ] Wizard: Ask if installer should advertise on Discord
- [x] Add [send "quit" to screen] for graceful shutdown
- [x] Add per-user time logging (session/day/all-time
- [ ] Do the above and 'figger out' how to do it with per-server settings

Notes:
If you get double quit notifications on player disconnect, it may be an anti-cheat problem.
Try disableing anti-cheat 22 in Zomboid Server configuration.
