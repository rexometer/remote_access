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
printf "#!/bin/bash\nsudo su -s /bin/sh autossh -c '/usr/bin/autossh -p22022 -fNC -M 0 -o \"ServerAliveInterval 30\" -o \"ServerAliveCountMax 3\" -R $portnumber:localhost:22  autossh@regenerix.de'" > /home/pi/rexometer/tunnel.sh
sudo chmod +x /home/pi/rexometer/tunnel.sh

echo "Add SSH-tunnel autostart to rc.local"
# see for more info to command: https://stackoverflow.com/a/17612421
sudo sed -i -e '$i \sh /home/pi/rexometer/tunnel.sh\n' /etc/rc.local

#add hash of server pub key to known_hosts
sudo su -c "echo '|1|9bvJZo7cU9HcUpvfFXADgqJ1v00=|+S+Gl3JAcUmFmWD7KDoyJJMDJEE= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKYY4LQkXu9rZRj1NCs8/Ss0PTfAq0vfYYvkZTr60bwl6NjRTFrY6/dx27Pz/72uM5W622GPvVCZcMwJvUuCeIg=' >> /home/autossh/.ssh/known_hosts" -s /bin/bash autossh
sudo su -c "echo '|1|D5Lrr0uNAUAvw2TSwc1ivwXBNmI=|QvADAR85pGO8AJ5f/F6BFaVfZNY= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKYY4LQkXu9rZRj1NCs8/Ss0PTfAq0vfYYvkZTr60bwl6NjRTFrY6/dx27Pz/72uM5W622GPvVCZcMwJvUuCeIg=' >> /home/autossh/.ssh/known_hosts" -s /bin/bash autossh

echo "Ok, the client is ready to open the tunnel"
echo "${bold}Now log into your server, switch to root and prompt this command:${normal}"
SSHKEY=$( sudo su -c "cat /home/autossh/.ssh/id_rsa.pub" -s /bin/sh autossh )
printf "echo %s_%s >> /home/autossh/.ssh/authorized_keys\n" "$SSHKEY" "$portnumber"
echo "${bold}After that reboot your pi. You can test if the tunnel works by logging into your server and execute 'ssh -p $portnumber pi@localhost'${normal}"

#ask if pi should be rebooted now
read -p "Reboot pi now (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        sudo reboot
    ;;
    * )
        echo No
    ;;
esac
