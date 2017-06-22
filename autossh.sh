#!/bin/bash
# configure autossh tunnel

sudo useradd -m -s /bin/false autossh
sudo su -s /bin/bash autossh
ssh-keygen
echo "Copy the public key. You need it later for the server side"
cat /home/autossh/.ssh/id_rsa.pub
su pi
sudo apt-get update
sudo apt-get install autossh
mkdir /home/pi/rexometer

echo "Please enter a unique port number (for example 22055)"
read portnumber
create_file /home/pi/rexometer/tunnel.sh
sudo chmod +x /home/pi/rexometer/tunnel.sh
echo "#!/bin/bash" > /home/pi/rexometer/tunnel.sh
echo "sudo su -s /bin/sh autossh -c '/usr/bin/autossh -p22022 -fNC -M 20000 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -R $portnumber:localhost:22  autossh@rexometer.com'" > /home/pi/rexometer/tunnel.sh

echo "Ok, the client is ready to open the tunnel"
echo "Now log into your server and prompt this command:  sudo su -s /bin/bash autossh"
echo "and add the clients public key at the end of this file: nano /home/autossh/.ssh/authorized_keys"
echo "You can test if the Tunnel works by logging into your server and execute 'ssh -p$portnumber pi@localhost'"
