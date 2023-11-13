const { Client, Intents } = require('discord.js');
const { spawn } = require('child_process');

const client = new Client({
  intents: [
    Intents.FLAGS.GUILDS,
    Intents.FLAGS.GUILD_MESSAGES,
  ],
});

const prefix = '!';
const targetChannelId = '<INSERT-YOUR-OWN-CHANNEL-ID-HERE>'; // Replace with the actual channel ID

client.on('messageCreate', (message) => {

  if (!message.content.startsWith(prefix) || message.author.bot) return;

  const args = message.content.slice(prefix.length).trim().split(/ +/);
  const command = args.shift().toLowerCase();

  if (command === 'status') {
    if (message.channel.id === targetChannelId) {
      executeCommand('/opt/dizcord/status.sh', message);
    } else {
      message.channel.send("You can only execute commands in the designated channel.");
    }
  } else if (command === 'start') {
    if (message.channel.id === targetChannelId) {
      message.channel.send("Zomboid is currently starting. Please give it a few seconds.");
      executeCommand('/opt/dizcord/start.sh');
    } else {
      message.channel.send("You can only execute commands in the designated channel.");
    }
  } else if (command === 'restart') {
    if (message.channel.id === targetChannelId) {
      message.channel.send("Zomboid will begin the reboot process. Please monitor #pz-updates for progress.");
      executeCommand('/opt/dizcord/restart.sh');
    } else {
      message.channel.send("You can only execute commands in the designated channel.");
    }
  }
});

function executeCommand(command, message) {
//  console.log('Executing command:', command);

  const childProcess = spawn(command, { shell: true });

  let output = '';

  childProcess.stdout.on('data', (data) => {
    output += data.toString();
  });

  childProcess.stderr.on('data', (data) => {
    output += data.toString();
  });

  childProcess.on('close', (code) => {
    if (code === 0) {
      message.channel.send(`${output}`);
    } else {
      console.error(`Command failed with code ${code}`);
      message.channel.send(`Error executing command:\n${output}`);
    }
  });
}

client.login('<INSERT-YOUR-OWN-DISCORD-BOT-TOKEN-HERE>');
