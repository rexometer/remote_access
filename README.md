# Add remote access to your Pi / emonPi / rexometer basestation
This maybe useful if your Pi is behind a Firewall without the possibility to open ports or if you use it with a mobile network connection.

For this to work you need a server wich is always on and reachable throught SSH from outside. Of course this could also be just a second Pi.
Execute this on the client side:

`git clone https://github.com/rexometer/remote_access.git && cd remote_access && sudo chmod +x autossh.sh && ./autossh.sh`
