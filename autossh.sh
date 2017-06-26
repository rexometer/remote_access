#!/bin/bash
# configure autossh tunnel
bold=$(tput bold) #for formating (make text bold)
normal=$(tput sgr0)

egrep -i "autossh" /etc/passwd;
if [ $? -eq 0 ]; then
   echo "User autossh already exists"
else
  sudo useradd -m -s /bin/false autossh
fi

sudo su -c "ssh-keygen -t rsa -N \"\" -f /home/autossh/.ssh/id_rsa" -s /bin/sh autossh

sudo apt-get update
sudo apt-get install autossh
mkdir /home/pi/rexometer

echo "${bold}Please enter a unique port number (for example 22055)${normal}"
read portnumber
printf "#!/bin/bash\nsudo su -s /bin/sh autossh -c '/usr/bin/autossh -p22022 -fNC -M 20000 -o \"ServerAliveInterval 30\" -o \"ServerAliveCountMax 3\" -R $portnumber:localhost:22  autossh@rexometer.com'" > /home/pi/rexometer/tunnel.sh
sudo chmod +x /home/pi/rexometer/tunnel.sh

echo "Add SSH-tunnel autostart to rc.local"
# see for more info to command: https://stackoverflow.com/a/17612421
sudo sed -i -e '$i \sh /home/pi/rexometer/tunnel.sh\n' /etc/rc.local

echo "Ok, the client is ready to open the tunnel"
echo "${bold}Now log into your server and prompt this command:${normal}"
SSHKEY=$( sudo su -c "cat /home/autossh/.ssh/id_rsa.pub" -s /bin/sh autossh )
printf "echo %s_%s >> /home/autossh/.ssh/authorized_keys\n" "$SSHKEY" "$portnumber"
echo "${bold}Now reboot your pi. You can test if the Tunnel works by logging into your server and execute 'ssh -p $portnumber pi@localhost'${normal}"
